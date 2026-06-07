# -*- coding:utf-8 -*-

import os
import sys
import csv
import argparse
import pandas as pd
from excel_diff_ja import compare_excel


def read_pair_list(csv_path):
    """
    CSVファイルから比較リストを読み込む
    
    CSV形式（最低でも最初の2列）：
      old_file,new_file,name
      ./path/to/file_A_v1.xlsx,./path/to/file_A_v2.xlsx,ファイルA
      ./path/to/file_B_v1.xlsx,./path/to/file_B_v2.xlsx,ファイルB
    """
    pairs = []
    with open(csv_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            old_file = row.get('old_file', '').strip()
            new_file = row.get('new_file', '').strip()
            name = row.get('name', '').strip()

            if not old_file or not new_file:
                print(f"  無効な行をスキップ: {row}")
                continue
            if not os.path.exists(old_file):
                print(f"  エラー：旧ファイルが見つかりません '{old_file}'、スキップ")
                continue
            if not os.path.exists(new_file):
                print(f"  エラー：新ファイルが見つかりません '{new_file}'、スキップ")
                continue

            if not name:
                name = f"{_short(old_file)}_vs_{_short(new_file)}"

            pairs.append((old_file, new_file, name))

    return pairs


def _short(path):
    return os.path.splitext(os.path.basename(path))[0]


def batch_compare(pairs, output_dir):
    """一括比較を実行"""
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

            # 各比較ペアの統計情報を集計
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
                if '(新規追加)' in sheet_name:
                    sheets_new += 1
                if '(削除済み)' in sheet_name:
                    sheets_del += 1

            has_changes = (total_add + total_del + total_mod) > 0 or sheets_new > 0 or sheets_del > 0

            summary_rows.append({
                'ファイル名': pair_name,
                '状態': '差異あり' if has_changes else '差異なし',
                '全Sheet数': len(all_stats),
                '新規Sheet': sheets_new,
                '削除Sheet': sheets_del,
                '総行数': total_rows,
                '追加行': total_add,
                '削除行': total_del,
                '変更行': total_mod,
                '変更なし': total_unch,
            })

        except Exception as e:
            print(f"  ❌ 比較失敗: {e}")
            import traceback
            traceback.print_exc()
            summary_rows.append({
                'ファイル名': pair_name,
                '状態': '比較失敗',
                '全Sheet数': 0,
                '新規Sheet': 0,
                '削除Sheet': 0,
                '総行数': 0,
                '追加行': 0,
                '削除行': 0,
                '変更行': 0,
                '変更なし': 0,
            })

    # 集計レポートを生成
    df = pd.DataFrame(summary_rows)
    summary_path = os.path.join(output_dir, 'batch_diff_summary.xlsx')
    df.to_excel(summary_path, index=False)
    print(f"\n{'='*70}")
    print(f"  ✅ すべて完了！処理したペア数: {total_pairs}")
    print(f"  ✅ 集計レポート: {summary_path}")
    print(f"  出力ディレクトリ: {output_dir}")
    print(f"{'='*70}")


def main():
    parser = argparse.ArgumentParser(description='Excelファイルの差分を一括比較')
    parser.add_argument('list_file', nargs='?',
                        help='CSVファイルのパス、old_file,new_file[,name] 列を含む')
    parser.add_argument('--output', '-o', default='./output',
                        help='出力ディレクトリ（デフォルト ./output）')

    args = parser.parse_args()

    if args.list_file:
        csv_path = args.list_file
    else:
        default_csv = 'diff_list.csv'
        if os.path.exists(default_csv):
            csv_path = default_csv
        else:
            print("使用方法: python batch_excel_diff_ja.py diff_list.csv")
            print("")
            print("CSV形式（1行目がヘッダー）:")
            print("  old_file,new_file,name")
            print("  ./dir/fileA_v1.xlsx,./dir/fileA_v2.xlsx,レポートA")
            print("  ./dir/fileB_v1.xlsx,./dir/fileB_v2.xlsx,レポートB")
            sys.exit(1)

    print(f"比較リストを読み込み: {csv_path}")
    pairs = read_pair_list(csv_path)

    if not pairs:
        print("有効な比較ペアがありません")
        sys.exit(1)

    print(f"合計 {len(pairs)} 組の比較:")
    for old_f, new_f, name in pairs:
        print(f"  {name}: {os.path.basename(old_f)} → {os.path.basename(new_f)}")

    batch_compare(pairs, args.output)


if __name__ == '__main__':
    main()
