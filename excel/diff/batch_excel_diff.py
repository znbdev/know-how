# -*- coding:utf-8 -*-

import os
import sys
import csv
import argparse
import pandas as pd
from excel_diff import compare_excel


def read_pair_list(csv_path):
    """
    从 CSV 文件读取对比列表
    
    CSV 格式（至少前两列）：
      old_file,new_file,name
      ./path/to/file_A_v1.xlsx,./path/to/file_A_v2.xlsx,文件A
      ./path/to/file_B_v1.xlsx,./path/to/file_B_v2.xlsx,文件B
    """
    pairs = []
    with open(csv_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            old_file = row.get('old_file', '').strip()
            new_file = row.get('new_file', '').strip()
            name = row.get('name', '').strip()

            if not old_file or not new_file:
                print(f"  跳过无效行: {row}")
                continue
            if not os.path.exists(old_file):
                print(f"  错误：找不到旧文件 '{old_file}'，跳过")
                continue
            if not os.path.exists(new_file):
                print(f"  错误：找不到新文件 '{new_file}'，跳过")
                continue

            if not name:
                name = f"{_short(old_file)}_vs_{_short(new_file)}"

            pairs.append((old_file, new_file, name))

    return pairs


def _short(path):
    return os.path.splitext(os.path.basename(path))[0]


def batch_compare(pairs, output_dir):
    """批量执行对比"""
    os.makedirs(output_dir, exist_ok=True)
    total_pairs = len(pairs)

    summary_rows = []

    for idx, (old_file, new_file, pair_name) in enumerate(pairs, 1):
        print(f"\n{'='*70}")
        print(f"  [{idx}/{total_pairs}] {pair_name}")
        print(f"  旧: {old_file}")
        print(f"  新: {new_file}")
        print(f"{'='*70}")

        try:
            all_stats = compare_excel(old_file, new_file,
                                      os.path.join(output_dir, f"diff_{pair_name}.txt"))

            # 汇总每组对比的统计信息
            total_rows = 0
            total_add = 0
            total_del = 0
            total_mod = 0
            total_unch = 0
            sheets_new = 0
            sheets_del = 0

            for sheet_name, st in all_stats.items():
                total_rows += st['added_rows'] + st['deleted_rows'] + st['modified_rows'] + st['unchanged_rows']
                total_add += st['added_rows']
                total_del += st['deleted_rows']
                total_mod += st['modified_rows']
                total_unch += st['unchanged_rows']
                if '(新增)' in sheet_name:
                    sheets_new += 1
                if '(已删除)' in sheet_name:
                    sheets_del += 1

            has_changes = (total_add + total_del + total_mod) > 0 or sheets_new > 0 or sheets_del > 0

            summary_rows.append({
                '文件名': pair_name,
                '状态': '有差异' if has_changes else '无差异',
                '总Sheet数': len(all_stats),
                '新增Sheet': sheets_new,
                '删除Sheet': sheets_del,
                '总行数': total_rows,
                '新增行': total_add,
                '删除行': total_del,
                '修改行': total_mod,
                '未变化': total_unch,
            })

        except Exception as e:
            print(f"  ❌ 对比失败: {e}")
            import traceback
            traceback.print_exc()
            summary_rows.append({
                '文件名': pair_name,
                '状态': '对比失败',
                '总Sheet数': 0,
                '新增Sheet': 0,
                '删除Sheet': 0,
                '总行数': 0,
                '新增行': 0,
                '删除行': 0,
                '修改行': 0,
                '未变化': 0,
            })

    # 生成汇总报告
    df = pd.DataFrame(summary_rows)
    summary_path = os.path.join(output_dir, 'batch_diff_summary.xlsx')
    df.to_excel(summary_path, index=False)
    print(f"\n{'='*70}")
    print(f"  ✅ 全部完成！共处理 {total_pairs} 组")
    print(f"  ✅ 汇总报告: {summary_path}")
    print(f"  输出目录: {output_dir}")
    print(f"{'='*70}")


def main():
    parser = argparse.ArgumentParser(description='批量对比 Excel 文件差异')
    parser.add_argument('list_file', nargs='?',
                        help='CSV 文件路径，包含 old_file,new_file[,name] 列')
    parser.add_argument('--output', '-o', default='./output',
                        help='输出目录（默认 ./output）')

    args = parser.parse_args()

    if args.list_file:
        csv_path = args.list_file
    else:
        default_csv = 'diff_list.csv'
        if os.path.exists(default_csv):
            csv_path = default_csv
        else:
            print("用法: python batch_excel_diff.py diff_list.csv")
            print("")
            print("CSV 格式（第一行为表头）:")
            print("  old_file,new_file,name")
            print("  ./dir/fileA_v1.xlsx,./dir/fileA_v2.xlsx,报表A")
            print("  ./dir/fileB_v1.xlsx,./dir/fileB_v2.xlsx,报表B")
            sys.exit(1)

    print(f"读取对比列表: {csv_path}")
    pairs = read_pair_list(csv_path)

    if not pairs:
        print("没有有效的对比对")
        sys.exit(1)

    print(f"共 {len(pairs)} 组对比:")
    for old_f, new_f, name in pairs:
        print(f"  {name}: {os.path.basename(old_f)} → {os.path.basename(new_f)}")

    batch_compare(pairs, args.output)


if __name__ == '__main__':
    main()
