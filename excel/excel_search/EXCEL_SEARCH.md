# Excel Content Search

Search Excel files (.xlsx/.xls) for cells containing a keyword.

## Usage

```bash
# Interactive mode
python excel_search.py

# CLI mode
python excel_search.py /path/to/folder keyword
```

## Output

- File path
- Sheet name
- Cell coordinate (e.g. A1, B3)
- Cell value (matched keyword highlighted with `[]`)

## File Structure

```
excel_search/
└── excel_search.py                    # search engine + terminal UI
```

## Dependencies

- `openpyxl` — Excel file reader
