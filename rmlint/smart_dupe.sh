#!/bin/bash

# 检查依赖
if ! command -v rmlint &> /dev/null; then
    echo "❌ 错误: 未检测到 rmlint。请先运行: brew install rmlint"
    exit 1
fi

SEARCH_PATH="$1"
if [ -z "$SEARCH_PATH" ]; then
    echo "使用方法: ./smart_dupe.sh [文件夹路径]"
    exit 1
fi

echo "--- 🎯 选择扫描模式 ---"
echo "1) 全量扫描 (所有文件)"
echo "2) 仅视频 (mp4, mkv, mov, avi)"
echo "3) 仅照片 (jpg, png, heic, raw)"
echo "4) 仅文档 (pdf, docx, xlsx, zip)"
read -p "请输入选项 [1-4]: " mode

case $mode in
    2) EXT="--match-extension mp4,mkv,mov,avi" ;;
    3) EXT="--match-extension jpg,jpeg,png,heic,raw" ;;
    4) EXT="--match-extension pdf,docx,xlsx,pptx,zip" ;;
    *) EXT="" ;;
esac

echo "🚀 开始扫描..."
rmlint $EXT -o sh:rmlint.sh -o csv:report.csv "$SEARCH_PATH"

if [ -f "rmlint.sh" ]; then
    DUP_COUNT=$(grep -c "^rm" rmlint.sh 2>/dev/null || echo "0")
    echo "✅ 扫描完成！发现重复项: $DUP_COUNT"
    echo "📄 报表已生成: report.csv"
    open -e rmlint.sh
else
    echo "💡 未发现重复文件。"
fi
