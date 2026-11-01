# PostgreSQL 200万级数据同步与性能测试计划 (本地环境)

## 1. 测试目标与范围
* **测试目的**：在本地 PC 环境下安全、无风险地验证 `m_packaging_code` 与 `w_packaging_code` 的数据同步逻辑，评估 200 万级数据在不同方案下的内存开销、执行时间及磁盘 I/O 表现。
* **测试范围**：
  * 单次全量 `MERGE` 与 `RETURNING` 历史追加的极速风险测试。
  * 应用层/存储过程分批同步（Batching）方案的稳定性与异常捕获验证。
  * `EXPLAIN ANALYZE` 执行计划诊断与 `work_mem` 调优验证。

---

## 2. 安全隔离与环境配置 (防崩卡/防污染)

为了防止测试过程中因内存耗尽导致本地操作系统卡死，或因日志膨胀挤爆本地硬盘，请按以下安全规范设置环境。

### 2.1 推荐架构方案：Docker 隔离运行
使用 Docker 运行容器化 PostgreSQL，限制其最高可用内存与 CPU 资源，确保宿主机不受影响。

```bash
# 启动隔离测试容器 (限制最多使用 4GB 内存和 2 核 CPU)
docker run --name pg-stress-test \
  -e POSTGRES_PASSWORD=LocalTestPass123! \
  -p 5432:5432 \
  --cpus="2.0" \
  --memory="4g" \
  -d postgres:16
```

> **如果不使用 Docker 直接安装在 Windows/Mac 上：**
> * 请保证安装目录所在盘符有至少 **20 GB 以上的可用空间**（防止 WAL 日志或临时文件撑爆硬盘）。
> * 确认 `postgresql.conf` 中 `listen_addresses = 'localhost'`，切勿暴露公网。

### 2.2 数据库参数预设 (Session 级别)
在执行任何测试前，在当前客户端会话中设定临时参数：

```sql
-- 放大工作内存以减少磁盘溢出，但在 Session 级别控制
SET work_mem = '64MB';
-- 开启 SQL 语句执行耗时打印
SET track_io_timing = ON;
```

---

## 3. 测试准备与模拟数据生成

在测试数据库中创建基础结构，并生成 200 万条模拟测试数据。

```sql
-- 1. 创建测试主表与工作表
CREATE TABLE m_packaging_code (
    packaging_code VARCHAR(50) NOT NULL,
    unit_dimension_code VARCHAR(50) NOT NULL,
    individual_pack_quantity INT,
    PRIMARY KEY (packaging_code, unit_dimension_code)
);

CREATE TABLE w_packaging_code (
    packaging_code VARCHAR(50) NOT NULL,
    unit_dimension_code VARCHAR(50) NOT NULL,
    individual_pack_quantity INT,
    PRIMARY KEY (packaging_code, unit_dimension_code)
);

CREATE TABLE r_packaging_code (
    id BIGSERIAL PRIMARY KEY,
    mode CHAR(1),
    before_after CHAR(1),
    packaging_code VARCHAR(50),
    unit_dimension_code VARCHAR(50),
    individual_pack_quantity INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sync_error_log (
    id SERIAL PRIMARY KEY,
    error_time TIMESTAMP,
    error_message TEXT,
    error_detail TEXT
);

-- 2. 生成 200 万条模拟数据 (包含新增、更新、删除三种场景)
-- 预加载 150 万数据到主表
INSERT INTO m_packaging_code (packaging_code, unit_dimension_code, individual_pack_quantity)
SELECT 
    'PKG_' || (g % 1500000),
    'DIM_' || (g % 100),
    (g % 50) + 1
FROM generate_series(1, 1500000) g;

-- 预加载 200 万数据到工作表 (150万匹配部分有更新，50万为纯新增，主表前50万将在同步中被删除)
INSERT INTO w_packaging_code (packaging_code, unit_dimension_code, individual_pack_quantity)
SELECT 
    'PKG_' || (g % 2000000),
    'DIM_' || (g % 100),
    (g % 50) + 2  -- 数量发生变动以触发 UPDATE
FROM generate_series(500001, 2500000) g;
```

---

## 4. 阶段性测试实施步骤

### 阶段 1：静态执行计划与瓶颈评估 (零风险)
在不修改任何数据的前提下，查看数据库预测的开销与资源消耗。

```sql
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
WITH merged AS (
    MERGE INTO m_packaging_code AS m
    USING w_packaging_code AS w ON (
        m.packaging_code = w.packaging_code 
        AND m.unit_dimension_code = w.unit_dimension_code
    )
    WHEN MATCHED AND m.individual_pack_quantity IS DISTINCT FROM w.individual_pack_quantity THEN
        UPDATE SET individual_pack_quantity = w.individual_pack_quantity
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (packaging_code, unit_dimension_code, individual_pack_quantity)
        VALUES (w.packaging_code, w.unit_dimension_code, w.individual_pack_quantity)
    WHEN NOT MATCHED BY SOURCE THEN
        DELETE
    RETURNING 
        merge_action() AS action,
        COALESCE(old.packaging_code, new.packaging_code) AS packaging_code,
        COALESCE(old.unit_dimension_code, new.unit_dimension_code) AS unit_dimension_code,
        old.individual_pack_quantity AS old_quantity,
        new.individual_pack_quantity AS new_quantity
)
SELECT COUNT(*) FROM merged;
```

* **监控重点**：
  1. 观察是否触发了 `Disk: xxx kB` 临时文件写入。
  2. 观察连接方式是 `Hash Join` 还是 `Seq Scan`。

---

### 阶段 2：小批量流式测试 (50,000 条验证)
测试包含历史写入逻辑的整体正确性与异常处理。

```sql
-- 建立测试保存点
BEGIN;

-- 限制当前只处理 50,000 条
WITH batch_w AS (
    SELECT * FROM w_packaging_code LIMIT 50000
),
merged AS (
    MERGE INTO m_packaging_code AS m
    USING batch_w AS w ON (
        m.packaging_code = w.packaging_code 
        AND m.unit_dimension_code = w.unit_dimension_code
    )
    WHEN MATCHED AND m.individual_pack_quantity IS DISTINCT FROM w.individual_pack_quantity THEN
        UPDATE SET individual_pack_quantity = w.individual_pack_quantity
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (packaging_code, unit_dimension_code, individual_pack_quantity)
        VALUES (w.packaging_code, w.unit_dimension_code, w.individual_pack_quantity)
    RETURNING 
        merge_action() AS action,
        COALESCE(old.packaging_code, new.packaging_code) AS packaging_code,
        COALESCE(old.unit_dimension_code, new.unit_dimension_code) AS unit_dimension_code,
        old.individual_pack_quantity AS old_quantity,
        new.individual_pack_quantity AS new_quantity
)
INSERT INTO r_packaging_code (mode, before_after, packaging_code, unit_dimension_code, individual_pack_quantity)
SELECT CASE action WHEN 'UPDATE' THEN 'u' WHEN 'DELETE' THEN 'd' END, 'b', packaging_code, unit_dimension_code, old_quantity FROM merged WHERE action IN ('UPDATE', 'DELETE')
UNION ALL
SELECT CASE action WHEN 'INSERT' THEN 'i' WHEN 'UPDATE' THEN 'u' END, 'a', packaging_code, unit_dimension_code, new_quantity FROM merged WHERE action IN ('INSERT', 'UPDATE');

-- 检查结果无误后撤销测试数据
ROLLBACK;
```

---

### 阶段 3：全量 200 万数据压力测试 (对比测试)

对比以下两种处理方式的运行指标：

| 测试项 | 方案 1: 单次全量 200 万条强行同步 | 方案 2: 应用层/分批处理 (每批 10,000 条) |
| :--- | :--- | :--- |
| **执行耗时** | 记录整体耗时 | 记录总耗时与每批平均耗时 |
| **内存峰值 (RAM)** | 观察本地/容器内存占用是否飙升至 100% | 观察内存曲线是否维持平稳 |
| **临时磁盘占用** | 查看 `pgsql_tmp` 尺寸变化 | 是否极少发生 Disk Spill |
| **锁表影响** | 评估挂起时间 | 评估其他查询并发可行性 |

---

## 5. 测试评价指标与结论记录表

请在测试完成后填写以下记录表格，作为生产环境方案选型的依据：

```markdown
### 测试结果记录面板

- 测试时间：YYYY-MM-DD
- 本地 CPU/内存配置：[例: 8核/16GB]
- PostgreSQL 版本：PostgreSQL [例: 16.2]

| 测试方案 | 成功/失败 | 执行总耗时 | 内存最大占用 | 产生临时文件大小 | 结论/建议 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 单次全量 200 万 | [ ] | __ 秒 | __ MB | __ MB | 不推荐/极易 OOM |
| 5000条/批 分批同步 | [ ] | __ 秒 | __ MB | __ MB | 推荐生产使用 |
| 10000条/批 分批同步| [ ] | __ 秒 | __ MB | __ MB | 最佳平衡点 |
```