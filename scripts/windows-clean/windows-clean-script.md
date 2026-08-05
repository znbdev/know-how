# Windows 智能清理脚本

智能扫描 Windows 上可清理的内容，自动区分「可直接删除」和「需用户判断」两类，并在**用户确认后**才真正删除，避免误删用户数据。

- 脚本路径: `scripts/windows-clean/smart-clean.ps1`
- Windows 版对应 macOS 版 `scripts/mac-clean/smart-clean.sh`

## 用法

在 PowerShell 中运行：

```powershell
# 仅扫描并列出可清理项（推荐先跑这个）
.\smart-clean.ps1 -List

# 进入交互确认模式（默认）
.\smart-clean.ps1 -Clean

# 自动清理所有[安全]项；[需判断]项仍逐个询问
.\smart-clean.ps1 -Yes

# 查看帮助
.\smart-clean.ps1 -Help
```

若系统执行策略阻止脚本（默认 `Restricted`），用绕过方式运行：

```bash
powershell -ExecutionPolicy Bypass -File .\scripts\windows-clean\smart-clean.ps1 -List
```

> **编码注意**：脚本包含中文注释/字符串，必须保持 **UTF-8 with BOM** 编码（文件头有 `EF BB BF`）。若用普通编辑器另存导致 BOM 丢失，Windows PowerShell 5.1 会按 ANSI 解析中文而报语法错误。PowerShell 7+ 则无此限制。

三种解除方式（从轻到重）：

```powershell
# 1) 临时放开当前会话（只影响当前 PowerShell 窗口，推荐）
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\smart-clean.ps1 -List

# 2) 永久允许当前用户运行本地/已签名脚本
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

# 3) 每次运行都绕过（无需改设置）
powershell -ExecutionPolicy Bypass -File .\smart-clean.ps1 -List
```

| 参数 | 行为 |
|------|------|
| `-List` | 只扫描、计算大小并列出两类清单，**不删除任何内容** |
| `-Clean` | 打印清单后进入交互确认，每个项目都需确认（默认） |
| `-Yes` | 自动清理所有 [安全] 项，[需判断] 项仍提问 |

## 输出分类

| 类型 | 含义 | 默认处理 |
|------|------|---------|
| **■ [安全]** | 可再生缓存 / 临时文件 / 崩溃转储，删除无风险 | `-Yes` 自动删，`-Clean` 逐项确认 |
| **■ [需判断]** | 可能含用户数据、正在使用、删除后需重装 | 始终需用户确认 |

只有占用 **≥ 10MB** 的项目才会被列出。

## 扫描范围

### [安全] 项（可再生缓存）
- `%TEMP%` / `%TMP%`（用户临时文件）
- `C:\Windows\Temp`（系统临时文件，需管理员）
- `C:\Windows\SoftwareDistribution\Download`（Windows 更新缓存）
- 缩略图缓存 `thumbcache_*.db`
- npm 缓存（`npm cache clean`）
- pip 缓存
- NuGet 缓存 `~\.nuget\packages`
- Windows 错误报告（WER）
- 崩溃转储 `*.dmp`、`*.hprof`
- 回收站（`Clear-RecycleBin`）

### [需判断] 项
- `~\.cache\huggingface`（本地推理模型缓存）
- `~\.codex`（Codex 配置/缓存）
- 全局 npm 大体积包（>200MB）
- 项目级 `node_modules`（>500MB，删除需重装）
- `Downloads` 中 >200MB 的大文件
- 用户目录下 >1GB 的大文件

## 工作机制

1. **扫描**：用 `Get-ChildItem` 递归求和计算每个候选路径的字节占用，仅列出超过阈值（10MB）者。
2. **分类**：命中安全模式（缓存/临时/转储）记为 `safe`，其余记为 `rev`（需判断）。
3. **展示**：分成两个清单打印，并汇总各自可释放的总空间。
4. **确认**：`-Clean`/`-Yes` 时先总体确认，再逐项确认；只有输入 `y` 才执行删除。
5. **复核**：删除后重算路径大小，仍有占用时给出 ⚠ 警告（仅提示，不做二次删除）。

## 安全性说明

- 默认只**列出**不删除；必须显式指定 `-Clean` 或 `-Yes` 才会真正执行。
- `[需判断]` 项（模型文件、`node_modules`、Download 大文件等）始终需逐项确认。
- 所有删除路径均通过 `-LiteralPath` 定位并加引号，避免含空格路径出错。
- 系统级项（`C:\Windows\Temp`、更新缓存等）可能被访问拒绝，需以管理员身份运行 PowerShell 才能生效。
- 建议先运行 `-List` 查看，再决定执行 `-Clean`。