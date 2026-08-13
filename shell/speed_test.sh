#!/bin/bash

# 定义报告输出路径（桌面）
REPORT_PATH="$HOME/Desktop/网速测试报告.txt"
DATE_STR=$(date "+%Y-%m-%d %H:%M:%S")

echo "=========================================="
echo "         Mac 本地网速诊断高级脚本         "
echo "=========================================="
echo "正在诊断中，请稍候（预计需要 20-30 秒）..."

# 1. 写入报告头部
echo "==========================================" > "$REPORT_PATH"
echo "        Mac 系统网速诊断报告 (Shell)      "
echo "==========================================" >> "$REPORT_PATH"
echo "测试时间: $DATE_STR" >> "$REPORT_PATH"
echo "" >> "$REPORT_PATH"

# 2. 获取当前网络环境信息
echo "[当前网络环境]" >> "$REPORT_PATH"
WIFI_NAME=$(ipconfig getsummary en0 2>/dev/null | grep "SSID" | awk -F': ' '{print $2}')
if [ -n "$WIFI_NAME" ]; then
    echo "连接类型: Wi-Fi" >> "$REPORT_PATH"
    echo "Wi-Fi 名称: $WIFI_NAME" >> "$REPORT_PATH"
else
    echo "连接类型: 有线网络/其他" >> "$REPORT_PATH"
fi
echo "" >> "$REPORT_PATH"

# 3. 运行 macOS 官方自带测试工具 (格式兼容优化版)
echo "[1/2] 正在运行 Apple 官方节点测试..."
echo "[测试 1: Apple 官方节点表现]" >> "$REPORT_PATH"

# 运行测速并捕获全量相关数据
APPLE_RESULT=$(networkquality -v 2>&1)
echo "$APPLE_RESULT" | grep -Ei "capacity|speed|bandwidth|responsiveness" >> "$REPORT_PATH"
echo "" >> "$REPORT_PATH"

# 4. 新增：基础连通性与网络稳定性测试 (Ping 核心骨干网)
echo "[2/2] 正在测试公共 DNS 延迟与稳定性..."
echo "[测试 2: 公共骨干网络延迟与丢包率]" >> "$REPORT_PATH"

# 使用 223.5.5.5 (国内公共DNS) 连续发送 5 个包测试稳定性
PING_RESULT=$(ping -c 5 223.5.5.5 2>&1)
if [ $? -eq 0 ]; then
    LOSS=$(echo "$PING_RESULT" | grep "packet loss" | awk -F', ' '{print $3}')
    RTT=$(echo "$PING_RESULT" | grep "round-trip" | awk -F' = ' '{print $2}')
    echo "连通性测试 (223.5.5.5): 成功" >> "$REPORT_PATH"
    echo "丢包率: $LOSS" >> "$REPORT_PATH"
    echo "延迟 (最小/平均/最大): $RTT" >> "$REPORT_PATH"
else
    echo "连通性测试 (223.5.5.5): 失败 (可能无互联网连接或防火墙拦截)" >> "$REPORT_PATH"
fi

echo "" >> "$REPORT_PATH"
echo "==========================================" >> "$REPORT_PATH"

# 提示用户
echo ""
echo "测试完成！"
echo "更精准的报告已覆盖生成至桌面，文件名：网速测试报告.txt"
echo "=========================================="
