import os
import pandas as pd
from datetime import datetime

def process_exact_case_mapping(excel_path):
    """
    从 Excel 中读取数据，只有当 table 的 key 集合与 case 的 key 集合
    【完全一致】时，才组合到一个 group。
    """
    if not os.path.exists(excel_path):
        print(f"错误：未找到 Excel 文件，请检查路径：{excel_path}")
        return

    print(f"正在读取文件: {excel_path} ...")

    # 1. 读取指定的两个 Sheet
    df_master = pd.read_excel(excel_path, sheet_name='master').fillna("")
    df_datas = pd.read_excel(excel_path, sheet_name='datas').fillna("")

    # ================= 核心处理逻辑 =================

    # 步骤一：解析 master 表，提取每个 case 要求的精确 key 集合
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

    # 步骤二：解析 datas 表，汇总每个 table 实际拥有的精确 key 集合
    if 'table' not in df_datas.columns or 'key' not in df_datas.columns:
        print("错误：'datas' 工作表中必须包含 'table' 和 'key' 两列！")
        return

    # 清洗字符串与空格
    df_datas['table'] = df_datas['table'].astype(str).str.strip()
    df_datas['key'] = df_datas['key'].astype(str).str.strip()

    # 按 table 分组并转为 set 集合
    table_groups = df_datas.groupby('table')['key'].apply(set).to_dict()

    # 步骤三：精准匹配（使用 == 确保完全一致）
    final_groups = {}
    for case_id, req_keys in case_requirements.items():
        matched_tables = []

        for t_name, t_keys in table_groups.items():
            # 💡 关键改动：从 issubset() 改为 ==
            # 只有两个集合的内容、数量完全一模一样时才为 True
            if req_keys == t_keys:
                matched_tables.append(t_name)

        final_groups[f"Case {case_id}"] = sorted(matched_tables)

    # ================= 打印最终结果 =================
    print("\n================ 精准对比分析结果 (完全一致) ================")
    for case_name, tables in final_groups.items():
        print(f"{case_name} 匹配到的 Table 组: {tables if tables else '[] (无完美匹配)'}")
    print("==========================================================")

    # ================= 生成 Excel 报表 =================
    script_dir = os.path.dirname(os.path.abspath(__file__))
    output_dir = os.path.join(script_dir, 'output')
    os.makedirs(output_dir, exist_ok=True)

    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    output_path = os.path.join(output_dir, f"mapping_result_{timestamp}.xlsx")

    with pd.ExcelWriter(output_path, engine='openpyxl') as writer:
        for case_name, tables in final_groups.items():
            if not tables:
                pd.DataFrame({"提示": ["无匹配的 table"]}).to_excel(writer, sheet_name=case_name[:31], index=False)
                continue
            df_group = df_datas[df_datas['table'].isin(tables)]
            sheet_name = case_name[:31]  # Excel sheet name max 31 chars
            df_group.to_excel(writer, sheet_name=sheet_name, index=False)

    print(f"\n✅ 报表已生成: {output_path}")

# ================= 配置与执行 =================
if __name__ == "__main__":
    # 请替换为您实际的 Excel 文件路径
    EXCEL_FILE_PATH = "./input/case_data_file.xlsx"

    # 执行处理
    process_exact_case_mapping(EXCEL_FILE_PATH)