# ForMac Shell 脚本集

macOS 磁盘管理与系统维护脚本，全部只读或需确认后才删除，不使用 sudo。

## 脚本一览

| 脚本 | 功能 | 操作级别 |
|------|------|----------|
| `disk-overview.sh` | 磁盘占用快速概览（卷使用率 + 家目录 Top） | 只读 |
| `disk-full-report.sh` | 完整磁盘扫描，生成 Markdown 报告 | 只读 |
| `disk-timeline.sh` | 按修改时间定位最近磁盘增长原因 | 只读 |
| `smart-clean.sh` | 交互式清理（安全/需判断分类） | 确认后删除 |
| `sys-health-check.sh` | 系统健康检查 + L1 安全清理 | 默认预演 |

---

## disk-overview.sh

快速查看当前磁盘占用情况。

```bash
bash disk-overview.sh           # 卷使用率 + 家目录 Top 10
bash disk-overview.sh --top     # 加扫系统顶层目录（/Applications 等）
bash disk-overview.sh --deep    # 加看 Caches/Developer/workspace 等明细
```

- 输出卷使用率进度条（绿/黄/红着色）
- 只读，不做任何删除

---

## disk-full-report.sh

生成完整磁盘扫描报告（Markdown 文件），包含：

- 总体概览（df）
- Library 目录占用
- 隐藏开发/AI 目录（.cache、.ollama、.npm 等）
- 开发环境与应用（Xcode、Docker、workspace）
- 大文件扫描（>200MB）
- 清理建议与可回收空间估算

```bash
bash disk-full-report.sh                    # 输出到 ../disk-report-YYYY-MM-DD.md
bash disk-full-report.sh /path/to/out.md    # 指定输出路径
```

- 只读，生成报告文件，不删除任何内容

---

## disk-timeline.sh

按文件修改时间分析磁盘占用，定位"最近磁盘是因为什么被占用的"。

```bash
bash disk-timeline.sh              # 默认：最近 3 天，>=50M 的大文件
bash disk-timeline.sh --days 7     # 扩大到最近 7 天
bash disk-timeline.sh --min 10M    # 降低文件大小阈值
bash disk-timeline.sh --dirs       # 按目录聚合（看哪个目录最近写入多）
bash disk-timeline.sh --all        # 文件 + 目录一起看
```

- 使用 macOS Spotlight（mdfind）索引，查询秒级完成
- 无 Spotlight 时自动退回 find（较慢）
- 先显示常见增长源体检（Docker/缓存/日志等），再列具体文件
- 只读，不做任何删除

---

## smart-clean.sh

交互式清理，扫描结果分为两类：

- **[安全]**：可再生缓存/临时文件/转储，删除无风险
- **[需判断]**：可能包含用户数据或正在使用，需用户确认

```bash
bash smart-clean.sh --list    # 仅扫描并列出，不删除
bash smart-clean.sh --clean   # 交互确认模式（推荐，默认）
bash smart-clean.sh --yes     # 直接删除所有 [安全] 项，[需判断] 项仍询问
```

- 覆盖：Caches、Logs、npm/pip/Homebrew 缓存、Xcode DerivedData、废纸篓等
- 废纸篓不自动清空（不可逆，需用户在 Finder 中处理）

---

## sys-health-check.sh

系统健康检查 + L1 级安全清理（兼容 Linux/macOS）。

```bash
bash sys-health-check.sh                  # 健康检查 + 优化预演（默认）
bash sys-health-check.sh --check          # 仅健康检查
bash sys-health-check.sh --optimize       # 仅优化预演（统计不删除）
bash sys-health-check.sh --optimize --execute  # 实际清理
```

健康检查项：CPU / 内存 / 磁盘 / 网络 / 启动项

安全承诺：
- 不使用 sudo，不碰系统目录
- 不碰个人文件（桌面/文档/下载/图片/视频）
- 不清空废纸篓
- 只删可再生的缓存、日志、临时文件
- 默认预演模式，实际删除需 `--execute`

---

## 使用建议

| 场景 | 推荐脚本 |
|------|----------|
| 快速看磁盘还剩多少 | `disk-overview.sh` |
| 月底做一次全面体检 | `disk-full-report.sh` |
| 磁盘突然变满，找原因 | `disk-timeline.sh` |
| 日常清理缓存 | `smart-clean.sh` |
| 系统变慢，全面检查 | `sys-health-check.sh` |
