## 🛠️ `rmlint` 快速上手手册 (macOS 版)

这份手册将帮助你从“扫描”到“安全清理”实现全流程自动化。`rmlint` 的强大之处在于它不仅能找重复文件，还能处理空文件夹、无效链接等磁盘垃圾。

---

### 1. 基础扫描命令

这是最常用的模式，它会扫描指定路径并生成 `rmlint.sh` 脚本。

```bash
rmlint /path/to/directory

```

### 2. 常用筛选参数 (提升效率)

如果你有数百万文件，通过参数缩小范围可以瞬间完成。

| 需求         | 命令参数                  | 说明                       |
|------------|-----------------------|--------------------------|
| **按大小过滤**  | `--size >50M`         | 只查找大于 50MB 的重复项（性价比最高）   |
| **排除文件夹**  | `-x /path/to/exclude` | 扫描时跳过特定的备份或系统目录          |
| **仅限同名文件** | `--must-match-stem`   | 只有内容相同 **且** 文件名也相同时才算重复 |
| **查找空目录**  | `-D`                  | 除了重复文件，顺便找出所有空文件夹        |
| **深度限制**   | `--max-depth 3`       | 只扫描到 3 层子文件夹，不继续往下挖      |

### 3. 决定“谁该被删” (核心逻辑)

`rmlint` 默认根据文件修改时间决定保留哪一个，但你可以人工干预：

* **保留最早的文件 (默认)**：`--rank-by mtime` (由旧到新)
* **保留路径最短的文件**：`--rank-by pathlen` (优先保留根目录下的，删除藏得深的)
* **指定优先保留目录**：

```bash
rmlint --keep-all-tagged /Volumes/Backup // /Volumes/Incoming

```

> **注意**：用 `//` 分隔。`//` 左边的路径被标记为“母本”，永远不会被删除。

---

## 🚀 执行删除的正确姿势

`rmlint` 扫描完后生成的 `rmlint.sh` 是一个保护罩。你必须通过以下方式运行它：

### 第一步：查看报告

运行完扫描后，直接在终端输入：

```bash
ls -l rmlint.sh

```

你可以打开它检查：`open -e rmlint.sh`（用文本编辑器查看）。

### 第二步：执行删除

```bash
# 模拟运行（不真删，只告诉你结果）
./rmlint.sh -n

# 真正执行删除并显示进度
./rmlint.sh -d -v

```

---

## 💡 针对 Mac APFS 格式的“黑科技”

如果你的 Mac 使用的是 SSD（系统版本 10.13+），磁盘格式通常是 **APFS**。APFS 支持 **克隆 (Reflink)** 功能。

如果你不想删除文件，但想**释放空间**，可以让两个重复文件共享同一块物理空间（即：文件还在，但只占一份空间）：

```bash
# 扫描并生成重构脚本
rmlint --clone /path/to/dir

# 执行克隆压缩
./rmlint.sh -c

```

*这在处理大量的项目代码、虚拟机镜像或照片库时极其有用且安全。*

---

### 总结工作流：

1. **安装**：`brew install rmlint`
2. **扫描**：`rmlint --size >1M /路径` (过滤掉碎小的系统文件)
3. **检查**：`cat rmlint.sh`
4. **清理**：`./rmlint.sh -d`

在使用 `rmlint` 扫描完成后，终端会打印出一份简报，而生成的 `rmlint.sh` 脚本中也会用特定的前缀标记处理对象的类型。理解这些符号能让你在执行删除前心中有数。

### 📋 `rmlint` 输出符号速查表

| 符号        | 含义                 | 说明                           |
|-----------|--------------------|------------------------------|
| **`[f]`** | **Original File**  | 原始文件。这是被选出的“母本”，**不会被删除**。   |
| **`[r]`** | **Duplicate File** | 重复文件。被识别为多余的副本，**会被列入删除计划**。 |
| **`[d]`** | **Directory**      | 目录。通常配合空目录扫描（`-D` 参数）出现。     |
| **`[l]`** | **Link**           | 软链接/硬链接。                     |
| **`[O]`** | **Other**          | 其他特殊类型文件（如管道、套接字等）。          |

---

### 如何在扫描时看懂实时简报？

当你运行 `rmlint` 时，终端底部的实时统计通常如下：

* **`Files scanned`**: 已经扫描过的文件总数。
* **`Duplicates found`**: 发现的重复文件数量。
* **`Total size`**: 重复文件占用的总磁盘空间（也就是你删掉它们后能省下的空间）。
* **`Time taken`**: 扫描耗时。

---

### ⚠️ 执行删除前的最后校验技巧

在运行 `./rmlint.sh -d` 之前，你可以使用 `grep` 命令快速过滤一下脚本内容，确保它没有包含你不想删除的目录：

```bash
# 检查删除清单中是否包含了“重要资料”文件夹
grep "rm" rmlint.sh | grep "重要资料"

```

如果你发现 `rmlint` 选错了“母本”（例如它想删掉 A 目录保留 B 目录，但你希望反过来），你不需要重新扫描，只需要在扫描时加上路径优先级：

```bash
# 让 /Volumes/SSD 里的文件成为“母本”(优先保留)
rmlint /Volumes/SSD // /Volumes/OldBackup

```

> **提示**：双斜杠 `//` 前面的路径会被赋予更高的 **Rank（等级）**，`rmlint` 会优先在这些路径中寻找并标记 `[f]` (Original)。

---

### 进阶：如何导出为可读的表格？

如果你觉得脚本太难看懂，想在 Excel 里核对，可以运行：

```bash
rmlint -o csv /你的路径 > report.csv

```

这样你就能在表格软件里清晰地看到：`哈希值`、`文件大小`、`文件路径`。

为了让你在处理海量文件时更加得心应手，我为你整合了一个**自动化工作流脚本**。

这个脚本会把 `rmlint` 的强大功能封装起来：它会自动开始扫描，完成后立即为你生成一份 CSV 报表供你核对，最后自动打开
`rmlint.sh` 脚本供你预览。

### 🚀 一键式去重工作流脚本：`dupe_flow.sh`

```bash
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

```

---

### 如何使用这个工作流？

1. **创建脚本**：

```bash
nano dupe_flow.sh

```

（粘贴上方代码，按 `Ctrl+O` 保存，`Ctrl+X` 退出）

2. **赋予权限**：

```bash
chmod +x dupe_flow.sh

```

3. **运行**：

```bash
./dupe_flow.sh /你的文件夹路径

```

---

### 📖 符号进阶：理解扫描报告中的隐藏细节

当你查看生成的 `report.csv` 时，你会发现 `rmlint` 已经帮你做好了分类。以下是你在核对时需要注意的：

* **Type 列**:
* `original`: 它是母本，脚本会保留它。
* `duplicate`: 它是副本，脚本会准备删除它。


* **Is_Dir 列**: 如果标记为 `True`，说明这整个文件夹都是空的或重复的。
* **Score 列**: `rmlint` 给出的可信度分数，分数越高表示重复的可能性越确定（基于哈希值）。

### 💡 核心安全建议

* **备份先行**：在处理非常重要的数据（如唯一的家庭照片库）前，建议先做一次 Time Machine 备份。
* **分批处理**：如果你的文件极其庞大，可以先针对某个子文件夹运行这个工作流，确认逻辑无误后再全局运行。

**如果你以后需要处理特定的文件类型（例如只清理重复的视频或只清理重复的照片），我可以帮你调整 `rmlint`
的过滤规则。需要我为你演示如何只针对特定后缀名进行扫描吗？**

针对特定文件类型（如视频、照片或文档）进行扫描，可以极大地减少扫描时间，并让你更专注于清理那些最占空间的大文件。

我们可以通过 `rmlint` 的 **`--match-extension`** 参数或者结合 Shell 的通配符来实现。

---

### 1. 针对特定后缀名的扫描命令

如果你只想处理特定的格式，可以使用以下命令模板：

#### 📺 场景 A：只清理重复视频 (最能释放空间)

视频通常体积巨大，清理重复视频的收益最高。

```bash
rmlint --match-extension "mp4,mkv,mov,avi" /你的路径

```

#### 📷 场景 B：只清理重复照片

```bash
rmlint --match-extension "jpg,jpeg,png,heic,raw" /你的路径

```

#### 📄 场景 C：只清理重复文档

```bash
rmlint --match-extension "pdf,docx,xlsx,pptx" /你的路径

```

---

### 2. 增强版自动化流：支持后缀筛选

我为你升级了之前的脚本，加入了一个简单的**交互式菜单**，让你在运行脚本时可以选择扫描模式。

```bash
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

```

---

### 3. 为什么按类型扫描更高效？

`rmlint` 在处理特定类型时有专门的优化逻辑：

* **避免扫描系统碎文件**：如果你选择“仅视频”，`rmlint` 会直接忽略掉成千上万个 `.txt`、`.json` 或系统缓存文件，**磁盘 I/O
  压力减小 90% 以上**。
* **哈希策略更准**：对于大视频文件，`rmlint` 会优先通过文件头（Header）判断格式，如果格式都不一致，直接跳过，速度极快。

---

### 4. 高级进阶：按文件名模糊匹配

如果你想找包含某个特定关键词（如“副本”或“Copy”）的重复文件，可以结合 `grep` 使用：

```bash
rmlint --match-stem /路径

```

`--match-stem` 参数要求两个文件**不仅内容一样，文件名（去掉后缀的部分）也必须一样**。这对于防止误删那些内容相同但用途不同的素材非常有效。

**既然你已经掌握了这些高级技巧，你需要我为你提供一个“定期自动扫描并报告”的定时任务（Crontab）设置方案吗？这样你的 Mac
就能自动保持整洁了。**

设置定时任务（Crontab）可以让你的 Mac 像拥有“自动清洁机器人”一样，定期扫描指定文件夹并在发现重复文件时向你发出提醒。

为了安全起见，我们设置的自动化任务**只负责扫描并生成报告**，绝不自动删除，由你决定何时执行清理。

### 步骤一：创建一个“静默扫描”脚本

首先，我们需要一个不需要交互、专门给后台运行的脚本。

1. 在终端输入 `nano ~/auto_scan.sh`。
2. 粘贴以下代码：

```bash
#!/bin/bash

# 设置扫描路径和报告存放路径
TARGET_DIR="/Users/你的用户名/Documents" # 修改为你实际想监控的路径
REPORT_DEST="/Users/你的用户名/Desktop/重复文件报告.txt"

# 运行 rmlint
# --size >100M 仅关注大文件，避免频繁打扰
# -o summary 仅输出总结
/usr/local/bin/rmlint --size ">100M" -o summary "$TARGET_DIR" > "$REPORT_DEST"

# 检查是否发现了重复项
if grep -q "Found" "$REPORT_DEST"; then
    # 使用 macOS 原生通知中心弹出提醒
    osascript -e "display notification \"发现重复大文件，请检查桌面报告\" with title \"定期磁盘清理提醒\""
fi

```

*(注：请通过执行 `which rmlint` 确认路径，如果是 M1/M2 Mac，路径通常是 `/opt/homebrew/bin/rmlint`)*

3. 保存退出并赋权：`chmod +x ~/auto_scan.sh`。

---

### 步骤二：设置 Crontab 定时计划

Crontab 是 macOS 内置的任务调度器。我们将其设置为**每周一早上 10:00** 自动运行。

1. 在终端输入：

```bash
crontab -e

```

2. 如果是第一次进入，按 `i` 进入编辑模式，在末尾添加一行：

```text
00 10 * * 1 /Users/你的用户名/auto_scan.sh

```

* **参数解释**：`00 10` (10点00分) `* * 1` (每周一)。


3. 按 `Esc` 键，输入 `:wq` 并回车保存。

---

### 步骤三：赋予“完全磁盘访问权限”

由于 macOS 的安全机制，后台运行的脚本默认无法读取你的“下载”、“文档”等文件夹。

1. 打开 **系统设置 (System Settings)**。
2. 进入 **隐私与安全性 (Privacy & Security)** -> **完全磁盘访问权限 (Full Disk Access)**。
3. 点击下面的 `+` 号，找到并添加 **终端 (Terminal)** 和 **/usr/sbin/cron**（或者给 `sh` 权限）。

---

### 💡 进阶：如果你更喜欢可视化提醒

如果你不习惯看 `.txt` 报告，可以修改脚本中的 `osascript` 部分，让它直接弹出对话框询问你是否要查看详细清单：

```bash
osascript -e 'display dialog "发现重复文件，是否现在查看报表？" buttons {"忽略", "查看"} default button "查看"'

```

### 总结

现在，你的 Mac 已经具备了：

* **高性能扫描** (rmlint)
* **智能过滤** (按文件类型/大小)
* **安全预览** (生成脚本但不自动删除)
* **自动监控** (Crontab 定时提醒)

**这就是一套完整的 macOS 企业级重复文件整理方案了。**
