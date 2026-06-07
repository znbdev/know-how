import os
import pandas as pd
from datetime import datetime

def process_exact_case_mapping(excel_path):
    """
    Excel からデータを読み込み、table の key 集合と case の key 集合が
    【完全一致】する場合のみ、同一グループにまとめる。
    """
    if not os.path.exists(excel_path):
        print(f"エラー：Excel ファイルが見つかりません。パスを確認してください：{excel_path}")
        return

    print(f"ファイルを読み込み中: {excel_path} ...")

    # 1. 指定された 2 つの Sheet を読み込む
    df_master = pd.read_excel(excel_path, sheet_name='master').fillna("")
    df_datas = pd.read_excel(excel_path, sheet_name='datas').fillna("")

    # ================= コア処理ロジック =================

    # ステップ1：master 表を解析し、各 case が必要とする key 集合を抽出
    case_requirements = {}
    case_col = df_master.columns[0]
    key_columns = df_master.columns[1:]

    for idx, row in df_master.iterrows():
        case_id = row[case_col]

        required_keys = set()
        for col in key_columns:
            val = str(row[col]).strip()
            if val in ['⭕️', '○']:
                required_keys.add(col)

        case_requirements[case_id] = required_keys

    # ステップ2：datas 表を解析し、各 table が実際に持つ key 集合を集計
    if 'table' not in df_datas.columns or 'key' not in df_datas.columns:
        print("エラー：'datas' ワークシートには 'table' と 'key' 列が必要です！")
        return

    # 文字列と空白をクリーニング
    df_datas['table'] = df_datas['table'].astype(str).str.strip()
    df_datas['key'] = df_datas['key'].astype(str).str.strip()

    # table ごとにグループ化し set に変換
    table_groups = df_datas.groupby('table')['key'].apply(set).to_dict()

    # ステップ3：完全一致マッチング（== を使用）
    final_groups = {}
    for case_id, req_keys in case_requirements.items():
        matched_tables = []

        for t_name, t_keys in table_groups.items():
            if req_keys == t_keys:
                matched_tables.append(t_name)

        final_groups[f"Case {case_id}"] = sorted(matched_tables)

    # ================= 結果表示 =================
    print("\n================ 完全一致マッチング結果 ================")
    for case_name, tables in final_groups.items():
        print(f"{case_name} にマッチした Table: {tables if tables else '[] (該当なし)'}")
    print("======================================================")

    # ================= Excel レポート生成 =================
    script_dir = os.path.dirname(os.path.abspath(__file__))
    output_dir = os.path.join(script_dir, 'output')
    os.makedirs(output_dir, exist_ok=True)

    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    output_path = os.path.join(output_dir, f"mapping_result_{timestamp}.xlsx")

    with pd.ExcelWriter(output_path, engine='openpyxl') as writer:
        for case_name, tables in final_groups.items():
            if not tables:
                pd.DataFrame({"備考": ["マッチする table がありません"]}).to_excel(writer, sheet_name=case_name[:31], index=False)
                continue
            df_group = df_datas[df_datas['table'].isin(tables)]
            sheet_name = case_name[:31]
            df_group.to_excel(writer, sheet_name=sheet_name, index=False)

    print(f"\n✅ レポートを生成しました: {output_path}")

# ================= 設定と実行 =================
if __name__ == "__main__":
    # 実際の Excel ファイルパスに変更してください
    EXCEL_FILE_PATH = "./input/case_data_file.xlsx"

    # 処理を実行
    process_exact_case_mapping(EXCEL_FILE_PATH)
