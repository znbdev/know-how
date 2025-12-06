#!/bin/bash

# --- 配置 ---
# 请将 YOUR_EMAIL@example.com 替换为你注册 GitHub 的邮箱地址
GIT_EMAIL="YOUR_EMAIL@example.com"
KEY_FILE="$HOME/.ssh/id_ed25519"
# ---

echo "🚀 开始 GitHub SSH Key 自动化配置..."
echo "--------------------------------------"

# 1. 检查并生成 SSH 密钥
if [ -f "$KEY_FILE" ]; then
    echo "⚠️ 发现现有 SSH 私钥文件: $KEY_FILE"
    echo "   **跳过密钥生成。**"
else
    echo "📝 正在生成新的 SSH 密钥对 ($KEY_FILE)..."
    # 使用 ed25519 算法生成密钥，-C 添加注释（你的邮箱）
    ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$KEY_FILE"
    # 提示用户设置一个安全的密码
    echo "✅ 密钥生成完成。"
fi

echo "--------------------------------------"

# 2. 启动 ssh-agent 并添加私钥
echo "🔑 正在启动 ssh-agent 并将私钥添加到其中..."

# 检查 ssh-agent 是否运行
if ! pgrep -q "ssh-agent"; then
    eval "$(ssh-agent -s)"
    echo "   ssh-agent 已启动。"
else
    echo "   ssh-agent 已经在运行。"
fi

# 尝试添加私钥，如果密钥有密码，它会提示你输入
if ssh-add -l | grep -q "$(ssh-keygen -lf $KEY_FILE)"; then
    echo "   私钥已在 ssh-agent 中。"
else
    ssh-add $KEY_FILE
    echo "   私钥已添加。"
fi

echo "--------------------------------------"

# 3. 复制公钥到剪贴板
PUBLIC_KEY_CONTENT=$(cat "$KEY_FILE.pub")
echo "📋 正在复制公钥内容到剪贴板..."

# 跨平台复制公钥内容
if command -v xclip &> /dev/null; then
    # Linux (需要安装 xclip)
    echo "$PUBLIC_KEY_CONTENT" | xclip -selection clipboard
    echo "   (使用 xclip) 已复制到剪贴板。"
elif command -v pbcopy &> /dev/null; then
    # macOS
    echo "$PUBLIC_KEY_CONTENT" | pbcopy
    echo "   (使用 pbcopy) 已复制到剪贴板。"
elif command -v clip &> /dev/null; then
    # Git Bash / Windows
    echo "$PUBLIC_KEY_CONTENT" | clip
    echo "   (使用 clip) 已复制到剪贴板。"
else
    echo "❌ 无法自动将公钥复制到剪贴板。你需要手动复制以下内容:"
    echo ""
    echo "**请手动复制以下全部内容:**"
    echo "--------------------------------------------------------"
    echo "$PUBLIC_KEY_CONTENT"
    echo "--------------------------------------------------------"
fi

echo "--------------------------------------"

# 4. 提示用户手动添加到 GitHub
echo "🌐 **下一步：手动将密钥添加到 GitHub**"
echo ""
echo "请执行以下操作，并在 GitHub 网站上粘贴剪贴板中的内容："
echo "1. 访问 GitHub SSH settings 页面: **https://github.com/settings/keys**"
echo "2. 点击 **New SSH key** (或 Add SSH key)。"
echo "3. 为密钥取一个易于识别的 **Title** (如: MyLaptop)。"
echo "4. 将剪贴板中的内容粘贴到 **Key** 字段。"
echo "5. 点击 **Add SSH key**。"
echo ""
echo "在完成添加后，你可以运行 'ssh -T git@github.com' 来测试连接。"
read -p "配置完成后，按 [Enter] 键继续测试..."

# 5. 测试连接
echo "--------------------------------------"
echo "🔗 正在测试与 GitHub 的 SSH 连接..."
ssh -T git@github.com

echo "--------------------------------------"
echo "🎉 脚本执行完毕。"