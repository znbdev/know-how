#!/bin/bash

# --- 配置项 ---
# 默认的 compose 文件名
COMPOSE_FILE="docker-compose.yml"
# 默认的 Podman Compose 命令
DEFAULT_COMMAND="up -d"
# ---

echo "--- 🐳 Podman Compose 自动化运行脚本 ---"

# 1. 检查 podman-compose 是否已安装
if command -v podman-compose &> /dev/null; then
    echo "✅ podman-compose 已安装。"
else
    echo "⚠️ podman-compose 未找到。尝试使用 pip 安装..."

    # 尝试使用 pip 或 pip3 安装
    if command -v pip &> /dev/null; then
        PIP_CMD="pip"
    elif command -v pip3 &> /dev/null; then
        PIP_CMD="pip3"
    else
        echo "❌ 错误：未找到 pip 或 pip3 命令。请手动安装 Python 和 pip，然后运行 'pip install podman-compose'。"
        exit 1
    fi

    echo "⚙️ 正在执行：$PIP_CMD install podman-compose"
    # 添加 --break-system-packages 允许在非虚拟环境中安装
    $PIP_CMD install podman-compose --break-system-packages

    # 再次检查安装是否成功
    if ! command -v podman-compose &> /dev/null; then
        echo "❌ 错误：podman-compose 安装失败。请检查您的 Python 和权限设置。"
        exit 1
    fi
    echo "✅ podman-compose 安装成功。"
fi

echo "--------------------------------------"

# 2. 检查 docker-compose 文件是否存在
if [ ! -f "$COMPOSE_FILE" ]; then
    echo "❌ 错误：在当前目录中找不到 Compose 文件: $COMPOSE_FILE"
    echo "   请确保您运行脚本的目录下有您的容器配置 YAML 文件。"
    exit 1
fi
echo "📄 找到 Compose 文件: $COMPOSE_FILE"

# 3. 确定要执行的命令
# 检查用户是否在脚本后传入了参数（例如：./script.sh down）
if [ -n "$1" ]; then
    COMMAND="$@" # 使用用户传入的所有参数作为命令
else
    COMMAND="$DEFAULT_COMMAND" # 使用默认命令
fi

echo "--------------------------------------"

# 4. 执行 podman-compose 命令
echo "▶️ 正在执行命令："
echo "   podman-compose $COMMAND"
echo ""

# 执行命令并保持脚本的退出状态码
podman-compose $COMMAND
EXIT_CODE=$?

echo "--------------------------------------"

# 5. 结果总结
if [ $EXIT_CODE -eq 0 ]; then
    echo "🎉 podman-compose 命令执行成功！"
else
    echo "⚠️ podman-compose 命令执行失败，退出代码为 $EXIT_CODE。"
fi

exit $EXIT_CODE