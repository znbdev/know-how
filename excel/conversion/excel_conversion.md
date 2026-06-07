# Excel Conversion Tool

## 概述

将 `datas` sheet 中的表格数据按 **key signature** 分组，每组生成一个独立 sheet 的卡片式布局。

## 输入格式（datas sheet）

| system | category | table | item | key |
|--------|----------|-------|------|-----|
| ATP | マスタ | 得意先 | StockCustomer | ○ |
| ATP | マスタ | 得意先シッピングパターン | 拠点番号 | ○ |

- `item`: 字段名
- `key`: `○` 表示该字段是主键，空表示非主键

## 分组逻辑

1. 按 `table` 分组，收集每个表的字段列表及 key 标记
2. 计算每个表的 **key signature**：所有标记 `○` 的字段集合
3. 按 key signature 合并表到同一 sheet

### 忽略项

`IGNORE_KEYS` 中的字段（如 `拠点番号`）不参与 key signature 计算（但仍显示为 PK）。
包含被忽略 key 的 sheet 标签以橙色标记，被忽略项以红色字体显示。

## 输出示例

**Sheet `得意先コード`**（橙色 tab，含被忽略 key）:

| システム | ATP | システム | ATP |
|----------|-----|----------|-----|
| テーブル | 得意先出荷 | テーブル | 得意先納入不可日 |
| 主キー | 项目名 | 備考 | 主キー | 项目名 | 備考 |
| PK | 得意先コード | | PK | 拠点番号（赤） | |
| | | | PK | 得意先コード | |
| | | | | シッピングアドレスコード | |

**Sheet `StockCustomer`**（无橙色 tab）:

| システム | ATP |
|----------|-----|
| テーブル | 得意先 |
| 主キー | 项目名 | 備考 |
| PK | StockCustomer | |

## 使用方法

```python
python excel_conversion.py
```

默认读取 `input/real_test_data.xlsx`，输出到 `output/exact_output_cards.xlsx`。

如需处理部分表，修改 `TABLES_TO_CONVERT`:

```python
TABLES_TO_CONVERT = ['得意先出荷', '得意先場所']  # 只处理指定表
TABLES_TO_CONVERT = None  # 处理全部表
```

## IGNORE_KEYS 配置

```python
IGNORE_KEYS = {'拠点番号'}  # 分组时忽略这些 key
```
