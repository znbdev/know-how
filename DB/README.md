# AI 驱动的数据库架构管理指南

## 🎯 核心目标
利用结构化格式（YAML / JSON Schema）提升 AI 对数据库表定义的理解精度，实现高效的 Text-to-SQL 交互与自动化维护。

---

## 💡 专家建议：最佳格式推荐

配合 AI 管理数据库时，最合适的格式是**“带有丰富自然语言元数据（Metadata）的 YAML”**。相比传统的 DDL 或纯文本，它在 AI 交互中具有显著优势。

### 为什么选择 YAML？

| 维度 | YAML (推荐) | JSON | 传统 SQL DDL |
| --- | --- | --- | --- |
| **AI 解析准确度** | **极高**（天然的结构化树状模型） | 高（但语法容错率低） | 中（受限于特定数据库方言） |
| **注释支持** | **原生支持** (`#`)，方便注入业务逻辑 | 不支持标准注释 | 仅靠 `COMMENT`，长度受限 |
| **Token 效率** | **更省**（无冗余符号，降低 AI 成本） | 较多（引号和逗号占用 Token） | 一般 |
| **元数据扩展性** | **极强**（可任意添加业务规则、AI 提示语） | 强（但结构较臃肿） | 弱 |
| **双向交互能力** | **完美**（AI 既能轻松读取，也能稳定输出） | 中（AI 易漏掉逗号导致解析失败） | 差 |

---

### 💡 结论与建议

1.  **首选 YAML**：如果你希望文件既能被程序读取，又能让人类轻松维护，且方便 AI 注入大量业务提示词（Hints/Rules），**YAML 是绝对的首选**。
2.  **何时用 JSON**：只有当你的下游工具（如某些老旧 API 或强制要求的配置加载器）**必须使用 JSON** 时，才考虑使用 JSON。

---

## 📝 标准管理模板（YAML 示例）

建议为每个核心表维护一个 `.yaml` 文件。你可以参考项目中的 [table_definition_example.yaml](./table_definition_example.yaml)。

```yaml
table_name: "users"
description: "系统核心用户表，存储用户基础账号信息及激活状态。"
business_domain: "用户中心"
ai_hints: "在进行用户留存分析或召回活动时，必须关联此表。严禁向非管理员暴露 password_hash。"

columns:
  - name: "id"
    type: "BIGINT"
    constraints: ["PRIMARY KEY", "AUTO_INCREMENT"]
    description: "自增主键，用户唯一标识"
    ai_rules: "作为关联其他业务表（如订单、日志）的外键"

  - name: "status"
    type: "VARCHAR(20)"
    constraints: ["DEFAULT 'pending'"]
    description: "用户账号状态"
    enums:
      pending: "注册未激活"
      active: "正常使用中"
      suspended: "因违规被封禁"
    ai_rules: "计算‘活跃用户’时，只需筛选 status = 'active'"
```

### 落地建议
1. **AI 提示词外置**：利用 `ai_hints` 和 `ai_rules` 字段告诉 AI 业务逻辑（例如：什么是“活跃用户”），能让 Text-to-SQL 准确率提升 80% 以上。
2. **版本控制**：将 YAML 文件托管在 Git 仓库中。修改表结构时，先改 YAML，再让 AI 生成对应的 SQL Alter 语句。

---

## 🚀 Oracle 到 PostgreSQL 转型方案

从 Oracle 转型为 PostgreSQL（PG）是一项系统工程，核心挑战在于处理 PL/SQL 存储过程、触发器及方言差异。

### 推荐的 AI 迁移工具组合

#### 1. 顶配专属：EDB Migration Portal + AI Copilot
*   **适用场景**：包含大量复杂存储过程的严苛业务。
*   **AI 能力**：集成基于 Azure AI 或本地私有化大模型的 **AI Copilot**。
*   **核心优势**：遇到无法自动转换的特性时，可直接通过 AI 聊天界面获取修复代码。

#### 2. 云原生利器：AWS SCT + AI 辅助修复
*   **工作流**：使用 AWS SCT 完成 60%-80% 的静态语法转换，剩余部分配合 **Cursor** 或 **GitHub Copilot** 进行语义重构。

#### 3. 开源生态：ora2pg + DeepSeek / ChatGPT
*   **工作流**：使用 `ora2pg` 导出 DDL，再利用 AI 将其清洗为前文提到的 YAML 格式，补全 `ai_hints` 后生成标准的 PG DDL。

---

## 🛠️ 转型期“AI 管理表定义”四步法

1.  **AI 结构化逆向解析**：让 AI 读取现有的 Oracle DDL，翻译成 YAML 格式，提取分区表、存储参数等特有属性。
2.  **语义映射与重构**：利用 AI 进行数据类型迁移映射（如：Oracle `NUMBER` -> PG `NUMERIC`）。
3.  **生成 PG 物理表结构**：把调整后的 YAML 丢给 AI，生成带有大量 COMMENT 注释的 PostgreSQL DDL。
4.  **补全 AI 元数据**：在 YAML 的 `ai_hints` 中记录迁移过程中的特殊处理（如：“某字段由触发器改为程序控制”）。

> ⚠️ **避坑指南**
> *   **空字符串与 NULL**：Oracle 视 `''` 为 `NULL`，而 PG 视其为不同值。务必在 AI 提示词中加入：*“请检查所有涉及空字符串判断的逻辑，并适配 PostgreSQL 语法。”*
> *   **大小写敏感**：Oracle 默认大写，PG 默认小写。建议在 DDL 中避免使用双引号，统一使用小写命名。