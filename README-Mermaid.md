Mermaid
=====

Mermaid 是一个用于绘制图表的开源工具。它使用 Markdown 语法来描述图表，并生成静态的 HTML 页面。

# Examples

### Entity-Relationship Diagram (ERD) ER图（实体关系图）

这是 Mermaid ER 图所有样式的完整示例，包含了实体、属性、关系以及它们的各种细节。

要渲染这段代码，你需要一个支持 **Mermaid ERD** 语法的编辑器，比如 **Typora**、**Obsidian** 或在线的 **Mermaid Live Editor**。

```mermaid
erDiagram
    %%--------------------------------------------------
    %% 实体定义 (Entity Definition)
    %%--------------------------------------------------
    CUSTOMER ||--o{ ORDER : has
    CUSTOMER {
        string customerId PK "客户ID"
        string name "客户姓名"
        string email "电子邮件"
        string address "地址"
    }

    ORDER ||--|{ ORDER_ITEM : contains
    ORDER {
        string orderId PK "订单ID"
        string orderDate "下单日期"
        string status "订单状态"
    }

    PRODUCT }|--|| ORDER_ITEM : is_in
    PRODUCT {
        string productId PK "产品ID"
        string productName "产品名称"
        int price "价格"
        int stock "库存数量"
    }

    SUPPLIER ||--|{ PRODUCT : supplies
    SUPPLIER {
        string supplierId PK "供应商ID"
        string name "供应商名称"
        string contact_person "联系人"
    }

    %%--------------------------------------------------
    %% 关系定义 (Relationship Definition)
    %%--------------------------------------------------
    %% 关系名称: `关系`
    %% 关系方向: `方向`
    %% 关系基数 (Cardinality): `基数`
    %% 实体名称1 `基数1`--`基数2` 实体名称2 : "关系名称"

    %% 一对多 (One-to-many): 一个顾客可以下多个订单
    CUSTOMER ||--o{ ORDER : places

    %% 一对一 (One-to-one): 一个员工可以有一个经理
    
    EMPLOYEE ||--|| MANAGER : reportsto


    EMPLOYEE {
        string employeeId PK "员工ID"
    }
    MANAGER {
        string managerId PK "经理ID"
    }

    %% 多对多 (Many-to-many): 一个学生可以选多门课程，一门课程可以被多个学生选
    STUDENT }|--|{ COURSE : registers for
    STUDENT {
        string studentId PK
    }
    COURSE {
        string courseId PK
    }

    %% 弱实体 (Weak Entity): 订单项依赖于订单
    ORDER ||--|{ ORDER_ITEM : contains

    %% 循环关系 (Recursive Relationship): 员工可以管理其他员工
    EMPLOYEE ||--o{ EMPLOYEE : manages

    %%--------------------------------------------------
    %% 属性类型和键 (Attribute Types & Keys)
    %%--------------------------------------------------
    %% 主键 (Primary Key): `PK` 或 `PK,FK`
    %% 外键 (Foreign Key): `FK`
    %% 必需属性 (Required): 默认为必需
    %% 可选属性 (Optional): 使用 `?`TODO这个好像无效
    %% 属性注释: "描述"
    
    ORDER {
        string orderId PK "主键"
        string customerId FK "外键"
        int orderTotal "订单总额"
    }

    PRODUCT {
        string productId PK "主键"
        string description "描述"
         date lastUpdated "可选日"
    }
```

### 样式解读

* **`erDiagram`**: 这是声明一个 ER 图的 Mermaid 关键字。
* **`实体名称 { ... }`**: 用大括号定义一个实体，并在其中列出它的属性。
* **`属性类型 属性名称 键 描述`**: 定义一个属性。
    * **`PK`**: **主键 (Primary Key)**，用于唯一标识实体。
    * **`FK`**: **外键 (Foreign Key)**，引用其他实体的主键。
    * **`?`**: 可选属性。如果省略，则默认为必需属性。
    * **`"描述"`**: 属性的中文描述或注释。
* **`实体1 基数1--基数2 实体2 : 关系`**: 定义实体间的关系。
    * **`||`**: **一对一**，代表“且只有一”。
    * **`|{`**: **一对多**，代表“一个或多个”。
    * **`o{`**: **零对多**，代表“零个或多个”。
    * **`|o`**: **零对一**，代表“零个或一”。
    * **`}`**: **多对多**，代表“一个或多个”。（注意，Mermaid 使用 `}|--|{` 来表示多对多）
* **`--`**: 关系线，连接两个实体。
* **`: 关系名称`**: 关系线的末尾可以加上冒号和关系名称，以提供更多信息。

# Reference

- [Mermaid 官方文档](https://mermaid.js.org/syntax/flowchart.html)
- [Mermaid Chart是一个在线工具，让用户通过简单的文本代码和AI快速创建各种专业图表，如流程图和序列图。](https://www.mermaidchart.com/app/projects/8fdff60c-2a2c-470a-ab5d-536d0fb0b6cf/diagrams/08e94010-88f6-4bd1-88c7-5b2752d979af/version/v0.1/edit)
- [Mermaid Live Editor(Github) 本地编辑，预览和共享Mermaid图表。](https://github.com/mermaid-js/mermaid-live-editor?tab=readme-ov-file)