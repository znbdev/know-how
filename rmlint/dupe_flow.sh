#!/bin/bash

# 检查是否安装了 rmlint
if ! command -v rmlint &> /dev/null; then
    echo "❌ 错误: 未检测到 rmlint。请先运行: brew install rmlint"
    exit 1
fi

SEARCH_PATH="$1"
if [ -z "$SEARCH_PATH" ]; then
    echo "使用方法: ./dupe_flow.sh [文件夹路径]"
    exit 1
fi

echo "--- 🛠️  rmlint 自动化流开始 ---"

# 1. 扫描并生成两种格式：脚本 (用于删除) 和 CSV (用于核对)
echo "🔍 步骤 1: 正在深度扫描 (跳过 1MB 以下的小碎文件以提速)..."
rmlint --size ">1M" -o sh:rmlint.sh -o csv:report.csv "$SEARCH_PATH"

# 2. 检查扫描结果
if [ ! -f "rmlint.sh" ]; then
    echo "❌ 扫描似乎未完成或未发现重复项。"
    exit 1
fi

# 3. 统计并展示成果
DUP_COUNT=$(grep -c "^rm" rmlint.sh 2>/dev/null || echo "0")
echo "✅ 扫描完成！"
echo "📍 发现重复文件数: $DUP_COUNT"
echo "📍 报表已生成: report.csv"
echo "📍 清理脚本已生成: rmlint.sh"

# 4. 自动打开报表和脚本供预览
echo "📖 步骤 2: 正在为你打开预览..."
open report.csv  # 在 Excel 或 Numbers 中打开
open -e rmlint.sh # 在文本编辑器中打开

echo "--- 💡 下一步指引 ---"
echo "1. 请在报表中核对是否有不应删除的文件。"
echo "2. 若确认无误，请在终端执行: ./rmlint.sh -d"
