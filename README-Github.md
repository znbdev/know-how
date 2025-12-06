Github
=====

To create an SSH key for GitHub, you can follow these steps:

### 1\. Check for Existing Keys

First, check if you already have an SSH key on your system. Open a terminal (Git Bash on Windows, Terminal on
macOS/Linux) and run the following command:

```bash
ls -al ~/.ssh
```

If you see files named `id_rsa.pub` or `id_ecdsa.pub`, you already have a key. If you don't want to overwrite it, you
can skip the next step.

-----

### 2\. Generate a New SSH Key

To generate a new SSH key, use the following command. Replace `"your_email@example.com"` with your GitHub email address.
The `-t ed25519` flag creates a new key using a modern, secure algorithm.

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

When prompted to "Enter a file in which to save the key," you can press **Enter** to accept the default location.

Next, you'll be asked to "Enter passphrase." It's highly recommended to **create a strong passphrase** for added
security. This passphrase will be required every time you use the SSH key. If you don't want a passphrase, you can press
**Enter** twice to leave it blank, but this is less secure.

-----

### 3\. Start the SSH Agent

The **SSH agent** manages your SSH keys and remembers your passphrase so you don't have to enter it every time you
connect. Start the agent in the background with this command:

```bash
eval "$(ssh-agent -s)"
```

-----

### 4\. Add Your SSH Key to the Agent

Now, add your newly created SSH key to the SSH agent. Use the following command. If you saved your key with a different
filename, be sure to use that instead of `id_ed25519`.

```bash
ssh-add ~/.ssh/id_ed25519
```

You'll be prompted to enter the passphrase you created in step 2.

-----

### 5\. Copy the SSH Key to Your Clipboard

To add the key to GitHub, you need to copy its content to your clipboard.

* **macOS:** `pbcopy < ~/.ssh/id_ed25519.pub`
* **Linux:** `xclip -sel clip < ~/.ssh/id_ed25519.pub` (you may need to install `xclip`)
* **Git Bash on Windows:** `clip < ~/.ssh/id_ed25519.pub`

-----

### 6\. Add the SSH Key to Your GitHub Account

Finally, add the copied key to your GitHub account.

1. Go to **GitHub** and click on your profile picture in the top-right corner.
2. Select **Settings**.
3. In the left sidebar, click **SSH and GPG keys**.
4. Click the **New SSH key** button.
5. In the "Title" field, give your key a descriptive name (e.g., "My Laptop").
6. Paste the key you copied in the "Key" field.
7. Click **Add SSH key**. You may be asked to enter your GitHub password to confirm.

-----

### 7\. Test the Connection

To verify that everything is set up correctly, open your terminal and run the following command:

```bash
ssh -T git@github.com
```

You will see a message like "Hi *username*\! You've successfully authenticated...". This confirms your SSH key is
working.

在 **Linux/macOS** 或使用 **Git Bash** 的 **Windows** 系统上，你可以使用一个 **shell 脚本** 来自动化生成 SSH 密钥并将其添加到 GitHub 账户。

下面是一个可以完成这些步骤的 Bash 脚本：

## 🔑 SSH 密钥自动化添加脚本 (Bash)

这个脚本会执行以下操作：

1.  检查系统中是否已存在 SSH 密钥（`id_rsa` 和 `id_rsa.pub`）。
2.  如果不存在，则使用你的 **GitHub 注册邮箱** 生成一个新的 SSH 密钥对（使用 `ed25519` 算法，更安全）。
3.  启动 `ssh-agent` 并将新生成的私钥添加到其中。
4.  将公钥内容复制到剪贴板，以便你可以轻松粘贴到 GitHub 网站上。
5.  **提示用户** 打开 GitHub 网站并手动粘贴密钥。

<!-- end list -->

```bash
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
```

-----

## 🛠️ 使用方法

1.  **保存脚本：** 将上面的代码保存为一个文件，例如 `add_github_ssh.sh`。

2.  **设置邮箱：** **务必** 将脚本中的 `GIT_EMAIL="YOUR_EMAIL@example.com"` 替换为你真实的 GitHub 注册邮箱。

3.  **赋予权限：** 打开你的终端（或 Git Bash），给脚本添加执行权限：

    ```bash
    chmod +x add_github_ssh.sh
    ```

4.  **运行脚本：** 执行脚本：

    ```bash
    ./add_github_ssh.sh
    ```

5.  **手动添加：**

      * 脚本运行到最后一步时，会提示你 **手动** 打开 GitHub 网站并添加密钥。
      * 因为涉及到 **账户登录和验证**，这是无法通过脚本自动完成的步骤。
      * 脚本已经将公钥内容复制到你的剪贴板，你只需在 GitHub 的 [SSH and GPG keys] 页面粘贴即可。

**注意：**

  * 在 **Linux** 上，如果脚本无法自动复制，你可能需要安装 `xclip` (`sudo apt-get install xclip` 或 `sudo yum install xclip`)。
  * 在 **macOS** 上，使用的是 `pbcopy`，通常默认安装。
  * 在 **Windows** 的 **Git Bash** 上，使用的是 `clip`。

-----

# Reference

[Adding a new SSH key to your GitHub account](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)
