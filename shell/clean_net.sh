#!/bin/bash

# 确保脚本以管理员权限运行
if [ "$EUID" -ne 0 ]; then
  echo "❌ 请使用 sudo 运行此脚本！"
  echo "正确用法: sudo sh $0"
  exit 1
fi

echo "🚀 开始清理 Mac 网络配置文件..."

# 定义目标目录和备份目录
TARGET_DIR="/Library/Preferences/SystemConfiguration"
BACKUP_DIR="$HOME/Desktop/Network_Config_Backup_$(date +%Y%m%d_%H%M%S)"

# 创建桌面备份文件夹，防止万一需要恢复
echo "📦 正在将旧配置文件备份至桌面..."
mkdir -p "$BACKUP_DIR"

# 需要清理的文件列表
FILES=(
  "com.apple.airport.preferences.plist"
  "NetworkInterfaces.plist"
  "preferences.plist"
)

# 循环备份并删除文件
for FILE in "${FILES[@]}"; do
  if [ -f "$TARGET_DIR/$FILE" ]; then
    cp "$TARGET_DIR/$FILE" "$BACKUP_DIR/"
    rm "$TARGET_DIR/$FILE"
    echo "✅ 已成功清理: $FILE"
  else
    echo "ℹ️ 未找到文件（可能已被删除）: $FILE"
  fi
done

echo "🎉 清理完成！旧文件已安全备份在桌面文件夹中。"
echo "⚠️ 为了让 Mac 重新生成干净的配置文件，系统将在 5 秒后自动重启..."
sleep 5

# 执行重启
shutdown -r now
