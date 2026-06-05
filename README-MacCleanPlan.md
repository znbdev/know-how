# Mac Clean Plan

## 1. 存储空间概览

```bash
# 查看磁盘使用情况
df -h /

# 查看各目录大小（从根目录开始）
sudo du -sh /* 2>/dev/null | sort -rh | head -20

# 查看当前用户目录下各隐藏目录大小
du -sh ~/.* 2>/dev/null | sort -rh | head -20

# 可视化磁盘使用情况
ncdu /        # 需要 brew install ncdu

# 查看各目录实际大小（排除隐藏文件）
du -sh ~/* | sort -rh | head -20
```

## 2. Finder 手动检查项

| 检查项 | 路径 | 说明 |
|--------|------|------|
| 下载文件夹 | `~/Downloads/` | 往往存了大量安装包、压缩包 |
| 废纸篓 | `~/.Trash/` | 可能占了几十 GB 未清空 |
| 邮件下载 | `~/Library/Mail/` | 附件缓存 |
| 消息附件 | `~/Library/Messages/` | iMessage 图片视频缓存 |
| 大型文件 | `~/Movies/`, `~/Music/` | 不再需要的媒体文件 |
| 重复文件 | 扫描整个用户目录 | 使用工具查找 |
| 应用程序 | `/Applications/` | 不再使用的旧应用 |

## 3. 清理缓存（Cache）

### 系统缓存

```bash
# 系统缓存（可安全清理）
sudo rm -rf /Library/Caches/*

# Xcode 缓存
rm -rf ~/Library/Caches/com.apple.dt.Xcode/*
rm -rf ~/Library/Developer/CoreSimulator/Caches/*

# Adobe 缓存（如安装了 Adobe 软件）
rm -rf ~/Library/Caches/com.adobe.*

# 字体缓存
sudo atsutil databases -remove
```

### 用户缓存

```bash
# 用户应用缓存（安全）
rm -rf ~/Library/Caches/*

# 浏览器缓存
rm -rf ~/Library/Caches/com.apple.Safari/*
rm -rf ~/Library/Caches/Google/Chrome/*  # 或 ~/Library/Caches/Google/Chrome/Default/Cache/*
rm -rf ~/Library/Caches/Firefox/*

# Spotify 缓存（如使用）
rm -rf ~/Library/Caches/com.spotify.client/*
```

## 4. 清理日志（Logs）

```bash
# 系统日志
sudo rm -rf /var/log/*

# 用户日志
rm -rf ~/Library/Logs/*

# 诊断报告
rm -rf ~/Library/Application\ Support/Diagnostics/*

# ASL 日志（Apple System Logs）
sudo rm -rf /var/log/asl/*.asl
```

## 5. 清理临时文件

```bash
# 系统临时文件
sudo rm -rf /private/var/tmp/*
sudo rm -rf /tmp/*

# 用户临时文件
rm -rf $TMPDIR/*
```

## 6. 清理开发环境

### Xcode

```bash
# Derived Data（构建缓存，可安全删除）
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# iOS 设备备份（旧备份可能很大）
rm -rf ~/Library/Application\ Support/MobileSync/Backup/*

# iOS DeviceSupport（各版本符号文件）
rm -rf ~/Library/Developer/Xcode/iOS\ DeviceSupport/*

# watchOS / tvOS DeviceSupport
rm -rf ~/Library/Developer/Xcode/watchOS\ DeviceSupport/*
rm -rf ~/Library/Developer/Xcode/tvOS\ DeviceSupport/*

# Archives（已归档的 App）
rm -rf ~/Library/Developer/Xcode/Archives/*

# Simulator 运行时
xcrun simctl delete unavailable
# 删除所有模拟器
xcrun simctl delete all

# 旧版 iOS 模拟器运行时（/Library/Developer/CoreSimulator/Images/）
# 或从 Xcode -> Settings -> Platforms 中手动删除
```

### Homebrew

```bash
# 清理旧版本
brew cleanup --prune=all
brew cleanup -s

# 卸载不再需要的包
brew autoremove

# 查看大体积包
brew list --formula | xargs -I {} sh -c 'echo "$(brew info {} | grep -E "^/")" {}' | sort -rh

# 缓存清理
rm -rf $(brew --cache)/*
```

### CocoaPods

```bash
# 清理 CocoaPods 缓存
pod cache clean --all
rm -rf ~/Library/Caches/CocoaPods/*
```

### Node / npm / yarn / pnpm

```bash
# node-gyp 缓存
rm -rf ~/.node-gyp/*

# npm 全局缓存
npm cache clean --force

# yarn 缓存
yarn cache clean

# pnpm 缓存
pnpm store prune
```

### Python

```bash
# pip 缓存
pip cache purge
pip3 cache purge
rm -rf ~/Library/Caches/pip/*
```

### Android

```bash
# Android Studio 缓存
rm -rf ~/.android/cache/*
rm -rf ~/Library/Caches/AndroidStudio*

# Gradle 缓存
rm -rf ~/.gradle/caches/*
```

### Rust

```bash
# Cargo 缓存
cargo cache  # 需要 cargo install cargo-cache
# 或手动
rm -rf ~/.cargo/registry/cache/*
```

### Go

```bash
# Go 模块缓存
go clean -cache
go clean -modcache
# 或手动
rm -rf $(go env GOPATH)/pkg/mod/cache/*
```

### Flutter

```bash
# Flutter 缓存
rm -rf ~/.pub-cache/*
flutter clean
```

## 7. 清理系统服务

### Time Machine 本地快照

```bash
# 查看本地快照
tmutil listlocalsnapshots /

# 删除所有本地快照
sudo tmutil deletelocalsnapshots /
# 或逐个删除
sudo tmutil deletelocalsnapshots / 2>/dev/null

# 禁用本地快照（不推荐，仅临时用）
sudo tmutil disablelocal
sudo tmutil enablelocal  # 重新启用
```

### 语言文件（可选：清理非中文语言包）

```bash
# 列出所有 .lproj 文件夹
ls /Applications/*.app/Contents/Resources/*.lproj/ 2>/dev/null

# 清理非中文语言文件（谨慎使用）
# 示例：只保留中文和英文
find /Applications -name "*.lproj" -not -name "zh*" -not -name "en*" -not -name "Base.lproj" | while read dir; do
    echo "rm -rf \"$dir\""
done
# 确认后再去掉 echo 执行
```

### 系统更新缓存

```bash
# macOS 更新下载包
sudo rm -rf /Library/Updates/*

# iOS 固件缓存（记得关掉自动更新下载）
sudo rm -rf /private/var/folders/*/*/*/com.apple.MobileSoftwareUpdate*
```

### 残留配置文件

```bash
# 已删除应用的残留配置文件
# 检查这些目录中是否还有已卸载的应用名目录
ls ~/Library/Preferences/
ls ~/Library/Application\ Support/
ls ~/Library/Containers/
```

## 8. 大型文件查找

```bash
# 全盘查找 > 1GB 的文件
sudo find / -type f -size +1G -exec ls -lh {} \; 2>/dev/null | sort -rh | head -50

# 查找 > 500MB 的文件
sudo find / -type f -size +500M -exec ls -lh {} \; 2>/dev/null | sort -rh | head -100

# 查找 > 100MB 且非系统文件
find ~ -type f -size +100M -exec ls -lh {} \; 2>/dev/null | sort -rh | head -100

# 使用 Spotlight 快速查找
mdfind 'kMDItemFSSize >= 1000000000' | head -30
```

## 9. Docker 清理（如使用）

```bash
# 查看占用
docker system df

# 彻底清理所有未使用的资源
docker system prune -a --volumes -f

# 清理特定资源
docker container prune -f
docker image prune -a -f
docker volume prune -f
docker network prune -f
```

## 10. 系统完整性工具

```bash
# 查看 "系统数据"（Other/System Data）占用
sudo du -sh /System/* | sort -rh | head -20

# 清理 iOS/iPadOS 固件缓存
sudo rm -rf ~/Library/iTunes/iPhone\ Software\ Updates/*
sudo rm -rf ~/Library/iTunes/iPad\ Software\ Updates/*

# 清理 .DS_Store 文件
sudo find / -name ".DS_Store" -type f -delete 2>/dev/null

# 清理系统核心转储
sudo rm -rf /cores/*
```

## 11. 定期自动清理脚本（crontab 参考）

创建脚本 `~/scripts/mac-clean.sh`:

```bash
#!/bin/bash
# 每周自动清理

# Cache
rm -rf ~/Library/Caches/* 2>/dev/null

# Trash
rm -rf ~/.Trash/* 2>/dev/null

# Xcode
rm -rf ~/Library/Developer/Xcode/DerivedData/* 2>/dev/null

# Homebrew
brew cleanup --prune=all 2>/dev/null
brew autoremove 2>/dev/null

# npm
npm cache clean --force 2>/dev/null

# Docker
docker system prune -af --volumes 2>/dev/null

# Logs
rm -rf ~/Library/Logs/* 2>/dev/null
```

```bash
# 添加到每周定时任务
chmod +x ~/scripts/mac-clean.sh
crontab -e
# 添加: 0 3 * * 0 ~/scripts/mac-clean.sh
```

## 12. 推荐的可视化工具

| 工具 | 安装方式 | 说明 |
|------|----------|------|
| ncdu | `brew install ncdu` | 终端界面的磁盘分析 |
| dupeguru | `brew install --cask dupeguru` | 查找重复文件 |
| omnidisksweeper | `brew install --cask omnidisksweeper` | 可视化磁盘分析 |
| grandperspective | `brew install --cask grandperspective` | 树图分析磁盘空间 |
| daisydisk | 付费 | 经典磁盘分析 |
| diskwave | `brew install --cask diskwave` | 可视化磁盘分析 |

## 清理前注意事项

- ⚠️ **建议先备份重要数据**，尤其是使用 `rm -rf` 的命令
- 部分缓存删除后应用首次启动会变慢（重建缓存）
- Docker 清理会丢失已停止的容器和未标记的镜像
- 建议按章节逐项执行，不要一次性全部执行
- 使用 `-rf` 前可以用 `ls` 确认目录内容
- 某些系统缓存可能需要重启后才能完全释放
