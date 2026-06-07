# Mac 清理报告

根据 [README-MacCleanPlan.md](./README-MacCleanPlan.md)，以下是可清理的文件分类报告。

---

## 1. 基础清理

| 清理项 | 位置 | 风险 |
|--------|------|------|
| 下载文件夹 | `~/Downloads/` | 低（手动确认） |
| 废纸篓 | `~/.Trash/` | 低 |
| 应用缓存 | `~/Library/Caches/*` | 低（重建后恢复） |
| 系统缓存 | `/Library/Caches/*` | 低 |
| 浏览器缓存 | Safari/Chrome/Firefox 缓存目录 | 低 |
| 日志文件 | `/var/log/*`, `~/Library/Logs/*` | 低 |
| 临时文件 | `/tmp/*`, `/private/var/tmp/*`, `$TMPDIR/*` | 低 |
| 诊断报告 | `~/Library/Application Support/Diagnostics/*` | 低 |
| ASL 日志 | `/var/log/asl/*.asl` | 低 |
| 语言文件 | 各 app 内的非中文 `.lproj` | 中（谨慎） |
| 系统更新缓存 | `/Library/Updates/*` | 低 |
| iOS 固件缓存 | iTunes 更新目录 | 低 |
| DS_Store 文件 | 全盘 | 低 |
| 核心转储 | `/cores/*` | 低 |
| 邮件/消息附件 | `~/Library/Mail/`, `~/Library/Messages/` | 中 |

---

## 2. Xcode 清理（通常很大）

| 清理项 | 预计空间 |
|--------|---------|
| DerivedData（构建缓存） | 几 GB ~ 几十 GB |
| iOS DeviceSupport | 各 iOS 版本符号文件 |
| Archives | 已归档 App |
| 模拟器运行时 | 几 GB ~ 几十 GB |
| iOS 备份 | 可能很大 |
| Xcode 缓存 | 几百 MB |

---

## 3. 开发工具缓存

| 工具 | 清理命令 | 预计空间 |
|------|---------|---------|
| Homebrew | `brew cleanup --prune=all` + `brew autoremove` | 几百 MB ~ 几 GB |
| CocoaPods | `pod cache clean --all` | 几百 MB |
| npm/yarn/pnpm | `npm cache clean --force` | 几百 MB ~ 几 GB |
| pip | `pip cache purge` | 几百 MB |
| Cargo (Rust) | `cargo cache` | 几百 MB ~ 几 GB |
| Go 模块 | `go clean -cache -modcache` | 几百 MB ~ 几 GB |
| Flutter | `rm -rf ~/.pub-cache/*` | 几百 MB |
| Gradle | `rm -rf ~/.gradle/caches/*` | 几百 MB ~ 几 GB |
| Android Studio | 缓存目录 | 几百 MB ~ 几 GB |

---

## 4. Docker

| 清理项 | 说明 |
|--------|------|
| 未使用容器/镜像/卷/网络 | `docker system prune -a --volumes -f` |

---

## 5. Time Machine 本地快照

| 清理项 | 说明 |
|--------|------|
| 本地快照 | `tmutil deletelocalsnapshots /` |

---

## 6. 大型文件

| 条件 | 命令 |
|------|------|
| > 1GB 文件 | `find / -type f -size +1G` |
| > 500MB 文件 | `find / -type f -size +500M` |
| 用户目录 > 100MB | `find ~ -type f -size +100M` |

---

## 建议操作顺序

1. **基础清理**（下载文件夹、废纸篓、缓存、日志、临时文件）
2. **开发环境**（Xcode → Homebrew → 各语言工具缓存 → Docker）
3. **系统服务**（Time Machine 快照、系统更新缓存）
4. **大型文件查找**（最后扫尾）

> ⚠️ 建议按章节逐项执行，不要一次性全部执行。使用 `rm -rf` 前先 `ls` 确认目录内容。
