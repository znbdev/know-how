Podman
=====

在 **Windows** 系统上，由于安全和权限机制的限制，**很难通过一个简单的 Bash 或 PowerShell 脚本完全自动化 Python 的下载、安装并配置环境变量的整个过程。**

这是因为：

1.  **权限和安装向导：** 官方的 Python 安装程序是一个 `.exe` 文件，它需要管理员权限，并通常需要用户在图形界面中手动**勾选 “Add Python to PATH”** 选项。脚本很难可靠地模拟这种图形界面操作并确保环境变量配置正确。
2.  **脚本兼容性：** 即使使用 PowerShell 脚本，也只能自动化下载 `.exe` 文件，但执行安装程序时仍然会弹出向导。

-----

## ✅ Windows 最佳自动化方案 (推荐步骤)

最接近“自动化”且最可靠的方法是使用 Windows 的包管理器 **`winget`**（Windows Package Manager）。它能简化安装过程，但仍需您执行几个命令。

### 步骤一：安装 Podman

在 Windows 上，Podman 推荐通过 **MSI 安装包** 安装。

1.  **下载 Podman MSI：**
    ```powershell
    # 使用 winget 下载 Podman 安装包
    winget install Podman
    ```
2.  **手动安装：** `winget` 会下载安装包，但您可能仍需双击运行它并完成安装向导。

### 步骤二：使用 winget 自动化安装 Python 和 pip

`winget` 可以实现无干扰地（Silent）安装 Python，并自动设置环境变量。

1.  **打开 PowerShell 或 CMD (推荐以管理员身份运行)**。

2.  **安装 Python 3：**

    ```powershell
    winget install Python.Python.3.11 --silent --location 'C:\Python3'
    ```

    > **注意：** 这里的版本号 (`3.11`) 可能会变化，您可以替换为当前最新稳定版。`--location` 选项指定安装路径，有助于配置。

3.  **验证和配置环境：**

    * 运行 `python --version` 确认安装成功。
    * 如果 `python` 命令找不到，您可能需要手动将 Python 安装路径（例如：`C:\Python3` 和 `C:\Python3\Scripts`）添加到系统的 **PATH 环境变量**中。

### 步骤三：安装 `podman-compose`

一旦 Python 和 `pip` 可用，安装 `podman-compose` 就非常简单了。

```powershell
pip install podman-compose
```

### 步骤四：创建最终的启动脚本

完成所有安装后，您可以创建一个简单的 **PowerShell 脚本** 来执行您的容器操作：

```powershell
# 文件名: start-compose.ps1

# 1. 验证 podman-compose 是否在 PATH 中
if (-not (Get-Command podman-compose -ErrorAction SilentlyContinue)) {
    Write-Error "错误：podman-compose 命令未找到。请确认已完成安装并重新启动终端。"
    exit 1
}

# 2. 确定命令 (默认 up -d)
$command = "up -d"
if ($args.Count -gt 0) {
    $command = $args -join " "
}

Write-Host ">>> 正在执行命令: podman-compose $command"
podman-compose $command

if ($LASTEXITCODE -eq 0) {
    Write-Host ">>> 命令执行成功。" -ForegroundColor Green
} else {
    Write-Host ">>> 命令执行失败，错误代码: $LASTEXITCODE" -ForegroundColor Red
}
```

**使用方法：**

```powershell
.\start-compose.ps1
# 或运行其他命令
.\start-compose.ps1 down
```

# Reference

[python downloads](https://www.python.org/downloads/)