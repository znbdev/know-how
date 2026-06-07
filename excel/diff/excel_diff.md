## Excel 文件差异对比工具

按行号对比两个 Excel 文件的所有 Sheet，输出两种格式的差异报告：

1. **文本报告**（`.txt`）— 详细列出每行每列的变更细节
2. **高亮 Excel**（`.xlsx`）— 用颜色标记新增、删除、修改的行和单元格

### 1. 环境准备

```bash
pip install pandas openpyxl
```

### 2. 使用方式

```python
from excel_diff import compare_excel

# 输出 .txt（同时自动生成 _highlight.xlsx）
compare_excel("v1_old.xlsx", "v2_new.xlsx", "diff_report.txt")

# 输出 .xlsx（同时自动生成 .txt）
compare_excel("v1_old.xlsx", "v2_new.xlsx", "diff_report.xlsx")
```

直接运行脚本：

```bash
python excel_diff.py
```

### 3. 高亮标记规则

| 类型 | Excel 颜色 | 说明 |
|------|-----------|------|
| 新增行 | 绿色 `#C6EFCE` | 整行背景 |
| 删除行 | 红色 `#FFC7CE` | 整行背景，显示旧版数据 |
| 修改行 | 淡黄 `#FFEB9C` | 整行背景 |
| 修改的单元格 | 亮橙 `#FF6347` | 仅变更的单元格高亮 |
| 表头 | 蓝底白字 `#4472C4` | |

### 4. 输出说明

- **文本报告**：包含统计摘要 + 每行详细变更记录（旧值/新值对比）
- **Excel 报告**：每个原始 Sheet 对应一个 Sheet，新增"汇总统计"Sheet
- 自动检测 Sheet 级别的新增/删除
- 自动检测列级别的新增/删除

### 5. Sheet 变更处理

| 场景 | 处理方式 |
|------|---------|
| 新旧文件共有的 Sheet | 按行号逐行对比，首行作为列名 |
| 仅在新文件中的 Sheet | 使用 `header=None` 读取，首行（标题行）作为数据保留，整 sheet 标记为新增（绿色） |
| 仅在旧文件中的 Sheet | 使用 `header=None` 读取，首行（标题行）作为数据保留，整 sheet 标记为删除（红色） |

### 6. 函数说明

```python
compare_excel(old_file, new_file, output_file)
```

| 参数 | 说明 |
|------|------|
| `old_file` | 旧版本 Excel 文件路径 |
| `new_file` | 新版本 Excel 文件路径 |
| `output_file` | 输出文件路径（`.txt` 或 `.xlsx`） |

输出文件命名规则：

| 传入路径 | 文本报告 | 高亮 Excel |
|---------|---------|-----------|
| `report.txt` | `report.txt` | `report_highlight.xlsx` |
| `report.xlsx` | `report.txt` | `report.xlsx` |

---

## 批量对比工具（batch_excel_diff.py）

通过 CSV 文件指定多组文件对，批量执行对比并生成汇总报告。

### CSV 格式

```csv
old_file,new_file,name
./财务_v1.xlsx,./财务_v2.xlsx,财务报表
./销售_v1.xlsx,./销售_v2.xlsx,销售报表
```

三列：`old_file`（旧文件）、`new_file`（新文件）、`name`（对比名称，可选）。

### 使用方式

```bash
python batch_excel_diff.py diff_list.csv
# 或省略参数，默认读取当前目录的 diff_list.csv
python batch_excel_diff.py
```

### 输出

```text
batch_output/
├── diff_财务报表.txt              # 详细差异报告
├── diff_财务报表_highlight.xlsx    # 高亮标记 Excel
├── diff_销售报表.txt
├── diff_销售报表_highlight.xlsx
└── batch_diff_summary.xlsx        # 汇总一览表
```

### 汇总报告（batch_diff_summary.xlsx）

| 列 | 说明 |
|---|------|
| 文件名 | 对比名称 |
| 状态 | 有差异 / 无差异 / 对比失败 |
| 总Sheet数 | 包含的 sheet 总数 |
| 新增Sheet / 删除Sheet | sheet 级别变化 |
| 新增行 / 删除行 / 修改行 | 单元格级别变化 |
| 未变化 | 无变化的行数 |
