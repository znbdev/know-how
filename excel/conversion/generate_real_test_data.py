import pandas as pd


def generate_test_input_excel(output_path):
    records = [
        # system  category  table  item  key
        ["ATP", "マスタ", "得意先",                   "StockCustomer",             "○"],
        ["ATP", "マスタ", "得意先シッピングパターン", "拠点番号",                 "○"],
        ["ATP", "マスタ", "得意先シッピングパターン", "得意先コード",             "○"],
        ["ATP", "マスタ", "得意先シッピングパターン", "シッピングアドレスコード", ""],
        ["ATP", "マスタ", "得意先シッピングパターン", "輸送区分",                 ""],
        ["ATP", "マスタ", "得意先出荷",               "得意先コード",             "○"],
        ["ATP", "マスタ", "得意先場所",               "拠点番号",                 "○"],
        ["ATP", "マスタ", "得意先場所",               "得意先コード",             ""],
        ["ATP", "マスタ", "得意先場所",               "シッピングアドレスコード", ""],
        ["ATP", "マスタ", "得意先納入不可日",         "拠点番号",                 "○"],
        ["ATP", "マスタ", "得意先納入不可日",         "得意先コード",             "○"],
        ["ATP", "マスタ", "得意先納入不可日",         "シッピングアドレスコード", ""],
        ["ATP", "マスタ", "得意先納入不可日",         "仓库コード",               ""],
        ["ATP", "マスタ", "得意先納入不可日",         "得意先納入不可日（FROM）", ""],
        ["ATP", "マスタ", "得意先納入不可日",         "得意先納入不可日（TO）",   ""],
        ["ATP", "マスタ", "得意先輸送",               "拠点番号",                 "○"],
        ["ATP", "マスタ", "得意先輸送",               "得意先コード",             "○"],
        ["ATP", "マスタ", "得意先輸送",               "シッピングアドレスコード", ""],
        ["ATP", "マスタ", "得意先輸送",               "仓库コード",               ""],
        ["ATP", "マスタ", "得意先輸送",               "物流業者コード",           ""],
        ["ATP", "マスタ", "得意先輸送",               "輸送区分",                 ""],
        ["FP",  "マスタ", "得意先マスタ",             "得意先コード",             "○"],
        ["ATP", "マスタ", "得意先別外装単位数設定",   "得意先コード",             "○"],
        ["ATP", "マスタ", "得意先別外装単位数設定",   "製作区分コード",           ""],
        ["ATP", "マスタ", "得意先別外装単位数設定",   "製造品番",                 ""],
    ]

    df = pd.DataFrame(records, columns=["system", "category", "table", "item", "key"])

    master_records = {
        "case": [1, 2, 3],
        "拠点番号": ["○", "", "○"],
        "得意先コード": ["○", "○", "○"],
        "シッピングアドレスコード": ["○", "", ""],
        "輸送区分": ["○", "", ""]
    }
    df_master = pd.DataFrame(master_records)

    with pd.ExcelWriter(output_path, engine='openpyxl') as writer:
        df.to_excel(writer, sheet_name='datas', index=False)
        df_master.to_excel(writer, sheet_name='master', index=False)

    print(f"Excel file generated: {output_path}")


if __name__ == "__main__":
    TARGET_FILE = "input/real_test_data.xlsx"
    generate_test_input_excel(TARGET_FILE)