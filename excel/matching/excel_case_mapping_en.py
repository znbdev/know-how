import os
import pandas as pd
from datetime import datetime

def process_exact_case_mapping(excel_path):
    """
    Reads data from an Excel file and groups tables with cases only when
    the table's key set is 【exactly identical】to the case's required key set.
    """
    if not os.path.exists(excel_path):
        print(f"Error: Excel file not found. Check path: {excel_path}")
        return

    print(f"Reading file: {excel_path} ...")

    # 1. Read the two required sheets
    df_master = pd.read_excel(excel_path, sheet_name='master').fillna("")
    df_datas = pd.read_excel(excel_path, sheet_name='datas').fillna("")

    # ================= Core Logic =================

    # Step 1: Parse master sheet, extract each case's required key set
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

    # Step 2: Parse datas sheet, aggregate each table's actual key set
    if 'table' not in df_datas.columns or 'key' not in df_datas.columns:
        print("Error: 'datas' sheet must contain both 'table' and 'key' columns!")
        return

    # Clean strings and whitespace
    df_datas['table'] = df_datas['table'].astype(str).str.strip()
    df_datas['key'] = df_datas['key'].astype(str).str.strip()

    # Group by table and convert to set
    table_groups = df_datas.groupby('table')['key'].apply(set).to_dict()

    # Step 3: Exact matching (using == for strict equality)
    final_groups = {}
    for case_id, req_keys in case_requirements.items():
        matched_tables = []

        for t_name, t_keys in table_groups.items():
            if req_keys == t_keys:
                matched_tables.append(t_name)

        final_groups[f"Case {case_id}"] = sorted(matched_tables)

    # ================= Print Results =================
    print("\n================ Exact Match Results ================")
    for case_name, tables in final_groups.items():
        print(f"{case_name} matched Tables: {tables if tables else '[] (no perfect match)'}")
    print("====================================================")

    # ================= Generate Excel Report =================
    script_dir = os.path.dirname(os.path.abspath(__file__))
    output_dir = os.path.join(script_dir, 'output')
    os.makedirs(output_dir, exist_ok=True)

    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    output_path = os.path.join(output_dir, f"mapping_result_{timestamp}.xlsx")

    with pd.ExcelWriter(output_path, engine='openpyxl') as writer:
        for case_name, tables in final_groups.items():
            if not tables:
                pd.DataFrame({"Note": ["No matching tables found"]}).to_excel(writer, sheet_name=case_name[:31], index=False)
                continue
            df_group = df_datas[df_datas['table'].isin(tables)]
            sheet_name = case_name[:31]
            df_group.to_excel(writer, sheet_name=sheet_name, index=False)

    print(f"\n✅ Report generated: {output_path}")

# ================= Configuration & Execution =================
if __name__ == "__main__":
    # Replace with your actual Excel file path
    EXCEL_FILE_PATH = "./input/case_data_file.xlsx"

    # Run the process
    process_exact_case_mapping(EXCEL_FILE_PATH)
