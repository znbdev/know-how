#!/bin/bash

# 定义报告输出路径（桌面）
REPORT_PATH="$HOME/Desktop/网速测试报告.txt"
DATE_STR=$(date "+%Y-%m-%d %H:%M:%S")

echo "=========================================="
echo "          Mac 本地网速自动化测试          "
echo "=========================================="
echo "正在测试中，请稍候（预计需要 15-30 秒）..."

# 1. 写入报告头部
echo "==========================================" > "$REPORT_PATH"
echo "        Mac 系统网速诊断报告 (Shell)      "
echo "==========================================" >> "$REPORT_PATH"
echo "测试时间: $DATE_STR" >> "$REPORT_PATH"
echo "" >> "$REPORT_PATH"

# 2. 获取当前网络环境信息
echo "[当前网络环境]" >> "$REPORT_PATH"
CURRENT_WIFI=$(networksetup -getadditionalroutes en0 2>/dev/null)
WIFI_NAME=$(ipconfig getsummary en0 | grep "SSID" | awk -F': ' '{print $2}')
if [ -n "$WIFI_NAME" ]; then
    echo "连接类型: Wi-Fi" >> "$REPORT_PATH"
    echo "Wi-Fi 名称: $WIFI_NAME" >> "$REPORT_PATH"
else
    echo "连接类型: 有线网络/其他" >> "$REPORT_PATH"
fi
echo "" >> "$REPORT_PATH"

# 3. 运行 macOS 官方自带测试工具 (networkquality)
echo "[1/2] 正在运行 Apple 官方节点测试..."
echo "[测试 1: Apple 官方节点表现]" >> "$REPORT_PATH"

# 捕获 networkquality 输出并格式化
APPLE_RESULT=$(networkquality -v 2>&1)
echo "$APPLE_RESULT" | grep -E "Upload capacity|Download capacity|Responsiveness" >> "$REPORT_PATH"
echo "" >> "$REPORT_PATH"

# 4. 尝试运行第三方 Speedtest CLI（如果系统里有的话）
echo "[2/2] 正在尝试运行 Speedtest 三方节点测试..."
echo "[测试 2: Speedtest.net 节点表现]" >> "$REPORT_PATH"

if command -v speedtest &> /dev/null; then
    # 已安装 speedtest-cli 或 官方 cli
    speedtest --result-description 2>&1 | grep -E "Download:|Upload:|Ping:" >> "$REPORT_PATH"
else
    echo "提示: 未安装 Speedtest CLI 命令行工具，已跳过此项。" >> "$REPORT_PATH"
    echo "如需更详细的数据，可在终端运行 'brew install speedtest-cli' 后重新测试。" >> "$REPORT_PATH"
fi

echo "" >> "$REPORT_PATH"
echo "==========================================" >> "$REPORT_PATH"
echo "报告生成成功！已保存在桌面。"

# 提示用户
echo ""
echo "测试完成！"
echo "报告已生成至桌面，文件名：网速测试报告.txt"
echo "=========================================="
