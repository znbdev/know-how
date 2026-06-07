# excel_case_mapping.py 概览

## 位置
`excle/matching/excel_case_mapping.py`

## 功能
从 Excel 文件中读取 **master** 和 **datas** 两个工作表，进行**精准 Key 集合匹配**：只有当 table 的 key 集合与 case 的 key 集合完全一致时，才将它们组合到一个 group 中。

## 核心流程

### 1. 解析 master 表
- 第一列为 case ID
- 其余列为候选 key
- 单元格值为 `⭕️` / `○` 时，该 key 被纳入该 case 的**必需 key 集合**

### 2. 解析 datas 表
- 必须包含 `table` 和 `key` 两列
- 按 `table` 分组，将同一 table 下的所有 key 转为 set 集合

### 3. 精准匹配
- 遍历每个 case 的必需 key 集合
- 与每个 table 的 key 集合进行 **`==` 比较**（非子集判断）
- 只有两个集合的**元素和数量完全一致**才算匹配成功

### 4. 输出
- 控制台：按 `Case {case_id}` 格式输出每个 case 命中的 table 列表
- Excel 报表：`./output/mapping_result_{时间戳}.xlsx`，每个 Case 一个 sheet，包含该组内所有 table 在 datas 中的全部行数据；若无匹配则 sheet 中仅含提示信息

## 用法
```bash
python excel_case_mapping.py
```

默认读取 `./input/case_data_file.xlsx`，可在 `__main__` 中修改 `EXCEL_FILE_PATH` 指定其他文件。

## 依赖
- `pandas` (读取 Excel)
- `openpyxl` (写入 Excel 报表)
- `os` (检查文件路径)
