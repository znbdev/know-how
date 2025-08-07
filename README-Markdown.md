markdown 语法
=====

大标题
=====

中标题
-----

# 一级标题

## 二级标题

### 三级标题

#### 四级标题

##### 五级标题

###### 六级标题

这是一段普通的文本，
直接回车不能换行，<br>
要使用\<br>
<br>注意第三行的\<br>前加了反斜杠 \ 。目的就是像其他语言那样实现转义，也就是 <  的转义。

插入单行引用
> 一盏灯，一片昏黄；一简书，一杯淡茶。守着那一份淡定，品读属于自己的寂寞。保持淡定，才能欣赏到最美丽的风景！保持淡定，人生从此不再寂寞。

*斜体字*
**粗体字**
***加粗斜体字***

List

- George Washington

* John Adams

+ Thomas Jefferson

1. James Madison
2. James Monroe
3. John Quincy Adams

Nested Lists

1. First list item
    - First nested list item
        - Second nested list item

Task lists

- [x] No.739
- [ ] https://github.com/octo-org/octo-repo/issues/740
- [ ] Add delight to the experience when all tasks are complete :tada:
- [ ] \(Optional) Open a followup issue

表格

| 表格  | 第一列 | 第二列 |
|-----|:---:|:---:|
| 第一行 | 第一列 | 第二列 |

分割线
***

***图片***
![This is an image](https://myoctocat.com/assets/images/base-octocat.svg)

***网络图片***
![Web image](https://avatars.githubusercontent.com/u/78408077?s=400&u=354a814d3eebe0872c37f5520174055893c95111&v=4)

***本地图片***
![Local image](images/logo.png)


<div style="background-color: #FF0000; padding: 20px; border-radius: 5px; color: #FFFFFF; font-size: 20px;">
    <strong>警告：</strong> 这里是警告信息。
</div>

# mermaid 例子

```mermaid
graph LR
    A(获取凭证) --> B{需要访问令牌?};
    B -- 是 --> C(请求访问令牌);
    C --> D(获取访问令牌);
    D --> E(包含凭证于请求);
    B -- 否 --> E;
    E --> F(发送API请求);
    F --> G{认证结果};
    G -- 成功(2xx) --> H(处理成功响应);
    G -- 失败(401) --> I(处理认证失败);
    I --> J{可刷新令牌?};
    J -- 是 --> K(使用刷新令牌请求新令牌);
    K --> D;
    J -- 否 --> L(重新获取凭证);
    L --> A;
    G -- 授权失败(403) --> M(处理授权失败);
    H --> N(完成);
    M --> N;
```

这是使用中心化的 SSO (Single Sign-On) 服务的方案的 Mermaid 示意图：

```mermaid
sequenceDiagram
    participant User
    participant SystemA (App 1)
    participant SystemB (App 2)
    participant SSO Server

    Note over User,SystemA: 用户尝试访问 SystemA
    User->>SystemA: 1. 访问受保护资源
    SystemA->>SSO Server: 2. 未认证，重定向到 SSO Server
    SSO Server->>User: 3. 显示 SSO 登录页面

    Note over User,SSO Server: 用户在 SSO Server 登录
    User->>SSO Server: 4. 提交登录凭据
    SSO Server->>SSO Server: 5. 验证凭据
    SSO Server->>User: 6. 设置 SSO 会话 Cookie
    SSO Server->>SystemA: 7. 重定向回 SystemA 并携带授权凭据 (e.g., Authorization Code)

    Note over SystemA,SSO Server: SystemA 验证授权凭据并获取令牌
    SystemA->>SSO Server: 8. 使用授权凭据向 SSO Server 请求 Access Token 和 ID Token
    SSO Server->>SystemA: 9. 返回 Access Token 和 ID Token
    SystemA->>User: 10. 授予访问权限 (使用 Access Token)
    SystemA-->>User: 11. 返回受保护资源

    Note over User,SystemB: 用户尝试访问 SystemB
    User->>SystemB: 12. 访问受保护资源
    SystemB->>SSO Server: 13. 未认证，重定向到 SSO Server
    SSO Server->>User: 14. 检测到已存在的 SSO 会话 (通过 SSO 会话 Cookie)
    SSO Server->>SystemB: 15. 重定向回 SystemB 并携带授权凭据

    Note over SystemB,SSO Server: SystemB 验证授权凭据并获取令牌
    SystemB->>SSO Server: 16. 使用授权凭据向 SSO Server 请求 Access Token 和 ID Token
    SSO Server->>SystemB: 17. 返回 Access Token 和 ID Token
    SystemB->>User: 18. 授予访问权限 (使用 Access Token)
    SystemB-->>User: 19. 返回受保护资源

    Note over User,SSO Server: 用户登出
    User->>SystemA: 20. 在 SystemA 触发登出
    SystemA->>SSO Server: 21. 请求 SSO Server 登出
    SSO Server->>SSO Server: 22. 清除 SSO 会话 Cookie
    SSO Server->>SystemA: 23. (可选) 重定向回 SystemA 登出确认
    SystemA-->>User: 24. 显示 SystemA 登出确认

    Note over User,SSO Server: 全局登出 (可选)
    SSO Server->>SystemB: 25. (可选) 向已登录的应用发送登出通知 (e.g., 通过 back-channel logout)
    SystemB->>User: 26. (可选) 清理 SystemB 本地会话
```

**图示说明：**

* **参与者 (Participants):** 用户、系统 A (你的 React/Next.js 应用)、系统 B (例如 PHP 博客)、SSO Server (中心化的认证服务)。
* **登录流程:**
    * 用户尝试访问系统 A 的受保护资源。
    * 系统 A 检测到用户未认证，将用户重定向到 SSO Server。
    * SSO Server 显示登录页面。
    * 用户在 SSO Server 提交凭据并成功登录。SSO Server 设置一个全局会话 Cookie。
    * SSO Server 将用户重定向回系统 A，并携带授权凭据（例如 OAuth 2.0 的授权码）。
    * 系统 A 使用授权凭据向 SSO Server 请求 Access Token 和 ID Token。
    * SSO Server 返回令牌。
    * 系统 A 使用 Access Token 授予用户访问权限。
* **访问其他系统 (System B):**
    * 用户尝试访问系统 B 的受保护资源。
    * 系统 B 检测到用户未认证，将用户重定向到 SSO Server。
    * SSO Server 检测到用户已经拥有有效的 SSO 会话 Cookie，直接将用户重定向回系统 B 并携带授权凭据，无需再次登录。
    * 系统 B 同样向 SSO Server 请求并获取令牌，然后授予用户访问权限。
* **登出流程:**
    * 用户在系统 A 触发登出。
    * 系统 A 通知 SSO Server 用户登出。
    * SSO Server 清除用户的全局会话 Cookie。
    * （可选）SSO Server 可以通知其他已登录的应用进行登出（例如通过 back-channel logout）。
    * 系统 A 完成本地登出。

# Reference

[Basic writing and formatting syntax](https://docs.github.com/cn/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax)

[gitconfig の基本を理解する](https://qiita.com/shionit/items/fb4a1a30538f8d335b35)

[github悬停显示文字](https://github.com "悬停显示文字")
