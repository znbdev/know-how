Github Repository classification management guide
=====

# GitHub 仓库分类管理指南

本文档详细记录了对 GitHub 仓库进行分类管理的方法、使用的命令和工具。

## 工具安装与使用

### GitHub CLI (gh)

GitHub CLI 是 GitHub 官方提供的命令行工具，可以方便地与 GitHub 进行交互。

#### 安装方法

根据不同操作系统，可以使用以下方法安装 GitHub CLI：

**macOS (使用 Homebrew):**

```bash
brew install gh
```

**Windows (使用 Chocolatey):**

```bash
choco install gh
```

**Ubuntu/Debian:**

```bash
sudo apt install gh
```

**其他安装方式:**
访问 [GitHub CLI 官方安装页面](https://github.com/cli/cli#installation) 获取更多安装选项。

#### 基本配置

安装完成后，需要进行身份验证：

```bash
gh auth login
```

按照提示选择认证方式，典型的配置过程如下：

```
? What account do you want to log into? GitHub.com
? What is your preferred protocol for Git operations on this host? SSH
? Generate a new SSH key to add to your GitHub account? Yes
? Enter a passphrase for your new SSH key (Optional)
? Title for your SSH key: GitHub CLI
? How would you like to authenticate GitHub CLI? Login with a web browser
```

参数说明：

- **What account do you want to log into?**: 选择要登录的 GitHub 账户类型，通常选择 GitHub.com
- **What is your preferred protocol for Git operations on this host?**: 选择 Git 操作的协议，推荐使用 SSH
- **Generate a new SSH key to add to your GitHub account?**: 是否生成新的 SSH 密钥，选择 Yes
- **Enter a passphrase for your new SSH key**: 为 SSH 密钥设置密码（可选）
- **Title for your SSH key**: 为 SSH 密钥设置标题，如 "GitHub CLI"
- **How would you like to authenticate GitHub CLI?**: 选择认证方式，推荐使用浏览器认证

#### 基本使用方法

- 查看帮助信息：

  ```bash
  gh --help
  ```

- 查看仓库相关命令：

  ```bash
  gh repo --help
  ```

- 编辑仓库信息：
  ```bash
  gh repo edit znbdev/know-how --description "Knowledge Summary"
  ```
  此命令将用户名为 `znbdev` 下的 `know-how` 仓库的描述信息更新为 "Knowledge Summary"。

## 使用的命令

### 1. 获取仓库列表

获取基本仓库列表：

```bash
gh repo list
```

获取详细信息的仓库列表（TXT 格式）：

```bash
gh repo list --limit 200 > repo_list.txt
```

参数说明：

- `--limit 200`: 限制返回的仓库数量（可根据实际需要调整）

获取详细信息的仓库列表（JSON 格式）：

```bash
gh repo list --limit 200 --json name,description,visibility,updatedAt,url > repo_details.json
```

参数说明：

- `--limit 200`: 限制返回的仓库数量（可根据实际需要调整）
- `--json`: 指定返回的字段
  - `name`: 仓库名称
  - `description`: 仓库描述
  - `visibility`: 可见性（PUBLIC/PRIVATE）
  - `updatedAt`: 最后更新时间
  - `url`: 仓库 URL

## 分类方法总结

### 1. 分析仓库信息

根据以下信息对仓库进行分类：

- 仓库名称中的关键词
- 仓库描述信息
- 技术栈相关命名（如 React、Spring、Docker 等）

### 2. 主要分类标准

根据仓库的技术领域和用途，将仓库分为以下主要类别：

1. **个人资料和配置相关**

   - 用于个人资料配置和开发环境设置的仓库

2. **前端开发相关**

   - 涉及前端技术栈、框架和组件的仓库
   - 细分为 React 相关、JavaScript/HTML/CSS 示例等

3. **后端开发相关**

   - 涉及后端服务、API 和服务器端技术的仓库
   - 细分为 Spring Boot 相关、Node.js/Express 相关、Java 相关等

4. **移动端开发相关**

   - 涉及移动应用开发的仓库

5. **Python 相关**

   - 使用 Python 语言开发的项目

6. **批处理和自动化相关**

   - 涉及批处理任务、自动化脚本的仓库

7. **系统运维和 DevOps 相关**

   - 涉及服务器配置、容器化、部署等运维相关的仓库
   - 细分为 Docker 和容器化相关、Nginx 和反向代理相关等

8. **多模块项目和示例**

   - 演示多模块项目结构的仓库

9. **人工智能和大数据相关**

   - 涉及 AI、机器学习、大数据处理的仓库

10. **工具和实用程序**

    - 各种工具和实用程序的仓库

11. **业务系统和企业应用**

    - 特定业务领域的系统和应用

12. **个人网站和博客**

    - 个人网站、博客和主页相关的仓库

13. **教育和学习相关**

    - 用于学习和教育目的的示例项目

14. **其他未分类项目**
    - 暂时无法明确分类的项目

### 3. 文档生成

将分类结果整理成结构化的 Markdown 文档，包含以下信息：

- 分类标题和说明
- 每个仓库的名称（带链接）、描述、类型和最后更新时间
- 表格形式展示，便于阅读和查找

## 实施步骤

1. **获取仓库数据**

   ```bash
   gh repo list --limit 200 --json name,description,visibility,updatedAt,url > repo_details.json
   ```

2. **分析数据**

   - 读取 JSON 文件
   - 根据仓库名称和描述分析其用途

3. **分类整理**

   - 按照分类标准将仓库归类
   - 记录每个仓库的基本信息

4. **生成文档**
   - 创建结构化的 Markdown 文档
   - 按分类组织内容，每个分类使用表格展示仓库信息

## 总结

通过使用 GitHub CLI 工具，我们可以方便地获取仓库信息并进行分类管理。这种方法可以帮助我们：

- 更好地了解和管理大量的 GitHub 仓库
- 快速找到特定技术领域的项目
- 识别可能需要归档或删除的仓库
- 为技术栈规划和学习路径提供参考

定期进行仓库分类管理有助于保持 GitHub 账户的整洁和有序。

---

### 🚀 方案一：Mac 终端彩色分类输出（并自动复制到剪贴板）

这行命令不仅会帮你在 Mac 终端里按语言将仓库分门别类，还会**自动把分类结果复制到你的 Mac 剪贴板**。你运行完后，直接去任何聊天软件或文档里 `Cmd + V` 就能粘贴！

请在终端中复制并运行以下命令（记得把 `你的用户名` 改掉）：

```zsh
gh repo list 你的用户名 --limit 1000 --json name,primaryLanguage,description --jq 'group_by(.primaryLanguage.name) | .[] | "\n========= 📦 \((.[0].primaryLanguage.name // "其他/未识别")) 语言类项目 =========", (.[] | "- \(.name) (\(.description // "暂无描述"))")' | tee /dev/tty | pbcopy

```

**💡 Mac 运行此命令的精妙之处：**

* `tee /dev/tty`：让结果**同时**显示在你的 Mac 屏幕上。
* `pbcopy`：macOS 独家命令，默默地把屏幕上显示的所有分类结果**存入你的系统剪贴板**。

---

### 🚀 方案二：生成一个漂亮的 Markdown 分类文件（放入你的笔记）

如果你想把分类结果保存为一个 `.md` 文件，方便导入到 Notion、Obsidian 或者作为你 GitHub 个人主页的素材，可以运行这一行：

```zsh
echo "# 我的 GitHub 仓库分类报告\n> 生成时间: $(date '+%Y-%m-%d')\n" > github_report.md && gh repo list 你的用户名 --limit 1000 --json name,primaryLanguage,description --jq 'group_by(.primaryLanguage.name) | .[] | "### 📂 \((.[0].primaryLanguage.name // "其他/未识别"))\n", (.[] | "* **\(.name)**: \(.description // "暂无描述")")' >> github_report.md && open github_report.md

```

**🎉 运行后的爽快体验：**
运行完毕后，你的 Mac 会**自动弹开**刚刚生成的 `github_report.md` 文件（通常会用 Mac 自带的文本编辑或你默认的 Markdown 编辑器打开），里面已经按照排版整整齐齐地分好了类！

---

##  完全可以！一键生成带超链接的 Markdown 报告

GitHub CLI 的 API 完美支持直接获取仓库的 `url`。我们只需要在请求的 JSON 字段中加上 `url`，并利用 `jq` 将其拼接成 Markdown 的标准链接格式 `[仓库名](URL)` 即可。

请直接复制以下优化后的命令到你的 **Mac 终端**中运行（记得把 `你的用户名` 改掉）：

```zsh
echo "# 我的 GitHub 仓库分类报告\n> 生成时间: $(date '+%Y-%m-%d')\n" > github_report.md && gh repo list 你的用户名 --limit 1000 --json name,primaryLanguage,description,url --jq 'group_by(.primaryLanguage.name) | .[] | "### 📂 \((.[0].primaryLanguage.name // "其他/未识别"))\n", (.[] | "* **[\(.name)](\(.url))**: \(.description // "暂无描述")")' >> github_report.md && open github_report.md

```

### 🎉 运行后的完美效果

运行后，Mac 依然会自动弹开 `github_report.md` 文件。文件内的排版会变成这样：

```markdown
# 我的 GitHub 仓库分类报告
> 生成时间: 2026-06-27

### 📂 Python
* **[data-analysis](https://github.com/你的用户名/data-analysis)**: 这是一个数据分析脚本
* **[web-scraper](https://github.com/你的用户名/web-scraper)**: 暂无描述

### 📂 TypeScript
* **[nextjs-blog](https://github.com/你的用户名/nextjs-blog)**: 我的个人博客前端项目

```

现在，无论是直接在支持 Markdown 的编辑器（如 Obsidian、Typora）里预览，还是直接复制到 Notion、GitHub Readme 中，**点击蓝色的仓库名字，就可以在浏览器中直接打开该仓库了！**

## 参考链接

- [GitHub CLI 文档](https://cli.github.com/manual/)
- [Easy GitHub CLI Installation & Authentication](https://www.youtube.com/watch?v=PPOL_hgMMLk)
