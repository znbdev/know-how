#### 一、 架构总览

* **方案定位**：STEP2 由「MuleSoft API → SpringBatch」调整为「调用 PostgreSQL 存储过程」，全部业务转换逻辑下沉到数据库内完成。
* **控制模型不变**：Hinemos 作业网 2-STEP 顺序控制保持原样，仅 STEP2 的执行形态变化。

```mermaid
flowchart TD
    SCH["Hinemos 调度定义<br/>每 3 小时启动一次作业网"] --> S1

    subgraph JU["Hinemos 作业网：DATA_MIGRATION_SYNC（2-STEP 控制）"]
        direction TB
        S1["STEP1：IDMC 同步作业<br/>调用 IDMC API 抽取并轮询至完成<br/>成功 exit 0 / 失败 exit 非0"]
        S2["STEP2：存储过程调用作业<br/>执行 CALL sp_migration_sync()"]
        S3["异常通知作业<br/>邮件/报警"]
        S1 -->|"等待条件：STEP1 终了状态=正常"| S2
        S1 -->|"等待条件：STEP1 终了状态=异常"| S3
    end

    subgraph SRC["源端：Spirits（Oracle DB）"]
        T20["同步表 20 张<br/>含 2 张约 200 万条级大表"]
    end

    subgraph ETL["数据集成层：IDMC（仅抽取 + 类型转换）"]
        INC["增量抽取（SQL）<br/>按更新时间戳，日间每 3 小时"]
        FULL["全量同步 / 清洗重置<br/>夜间执行，含已删除数据"]
    end

    subgraph PGDB["目标端：Prism（PostgreSQL，新设 8 张表）"]
        direction TB
        SP["存储过程 sp_migration_sync()<br/>流程控制 + 分块 COMMIT + 异常处理"]
        STG["接入层：临时导入表（取込用テーブル）"]
        TGT["转换层：符合 Prism 规范的 8 张目标表"]
        HIS["历史层：历史变更数据记录"]
        MGMT["同步管理表<br/>批次状态 / 断点水位"]
        STG --> TGT --> HIS
        SP -.->|"驱动处理"| STG
        SP -.->|"驱动处理"| TGT
        SP -.->|"驱动处理"| HIS
        SP -.->|"记录状态"| MGMT
    end

    T20 --> INC
    T20 --> FULL
    INC -->|"类型转换（Oracle → PG）"| STG
    FULL -->|"类型转换（Oracle → PG）"| STG
    S2 --> SP
```


#### 二、 STEP2 存储过程内部流程

```mermaid
flowchart TD
    CALL["Hinemos STEP2<br/>CALL sp_migration_sync()"] --> W1["同步管理表写入批次状态<br/>RUNNING + 记录起始水位"]
    W1 --> W2["读取同步管理表断点水位<br/>确定本次处理起点"]
    W2 --> P1["转换层：集合式 INSERT ... SELECT / MERGE<br/>基于临时导入表生成 8 张目标表<br/>每 N 行分块 COMMIT"]
    P1 --> P2["历史层：捕获变更前后镜像<br/>写入历史变更记录<br/>每 N 行分块 COMMIT"]
    P2 --> CHK{"全部表处理完成？"}
    CHK -->|"是"| OK["同步管理表更新为 SUCCESS<br/>推进水位"]
    CHK -->|"否 / 异常"| NG["EXCEPTION 捕获<br/>回滚当前块并保留已提交断点<br/>同步管理表更新为 FAILED + 错误信息"]
    OK --> R1["exit 0<br/>Hinemos 进入正常收尾"]
    NG --> R2["exit 非 0<br/>Hinemos 异常通知作业告警<br/>下一轮调度照常执行"]
```


#### 三、 执行时序

```mermaid
sequenceDiagram
    autonumber
    participant H as Hinemos 作业网
    participant I as IDMC
    participant O as Oracle 源端
    participant P as PostgreSQL（Prism）
    participant M as 同步管理表

    H->>I: STEP1 启动 IDMC 抽取
    I->>O: 按更新时间戳读取 20 张表
    I->>P: 类型转换后写入临时导入表（Oracle → PG）
    I-->>H: 同步完成，exit 0
    Note over H: 等待条件满足（STEP1 终了状态=正常）
    H->>P: STEP2 执行 CALL sp_migration_sync()
    P->>M: 写入批次状态 RUNNING + 断点水位
    P->>P: 转换层生成 8 张目标表（分块 COMMIT）
    P->>P: 历史层写入变更记录（分块 COMMIT）
    P->>M: 更新批次状态 SUCCESS + 推进水位
    P-->>H: exit 0（异常时 exit 非 0 → 告警）
```


#### 四、 关键设计要点

* **2-STEP 控制保持不变**：STEP1 成功才执行 STEP2，Hinemos 等待条件与「条件未满足立即结束」机制照常适用。
* **跨库类型转换仅在 STEP1**：IDMC 完成 Oracle → PG 类型落地，存储过程输入输出全为 PG 类型，无跨库转换。
* **分块 COMMIT 防长事务**：200 万级大表按每 N 行提交，降低锁与 vacuum 压力（PG 11+ 过程内事务控制）。
* **断点续传**：同步管理表记录断点水位，异常中断后下次执行从水位处继续，已完成分块不重复处理。
* **异常隔离**：EXCEPTION 捕获失败批次并回滚当前块，同步管理表记录错误信息，失败仅影响当次，不阻塞下一轮调度。
* **成本零增量**：无 SpringBatch/MuleSoft 运行时开销，IDMC 计费仅取决于抽取时长与行数，不受本层影响。

**【约束条件】**
严格按照逻辑分块输出，清晰明确，一律使用正向表述与简体中文呈现。
