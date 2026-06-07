# -*- coding:utf-8 -*-

import os
import sys
import csv
import argparse
import pandas as pd
from excel_diff_en import compare_excel


def read_pair_list(csv_path):
    """
    Read comparison list from CSV file

    CSV format (at least first two columns):
      old_file,new_file,name
      ./path/to/file_A_v1.xlsx,./path/to/file_A_v2.xlsx,File A
      ./path/to/file_B_v1.xlsx,./path/to/file_B_v2.xlsx,File B
    """
    pairs = []
    with open(csv_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            old_file = row.get('old_file', '').strip()
            new_file = row.get('new_file', '').strip()
            name = row.get('name', '').strip()

            if not old_file or not new_file:
                print(f"  Skipping invalid row: {row}")
                continue
            if not os.path.exists(old_file):
                print(f"  Error: Cannot find old file '{old_file}', skipping")
                continue
            if not os.path.exists(new_file):
                print(f"  Error: Cannot find new file '{new_file}', skipping")
                continue

            if not name:
                name = f"{_short(old_file)}_vs_{_short(new_file)}"

            pairs.append((old_file, new_file, name))

    return pairs


def _short(path):
    return os.path.splitext(os.path.basename(path))[0]


def batch_compare(pairs, output_dir):
    """Batch compare all pairs"""
    os.makedirs(output_dir, exist_ok=True)
    total_pairs = len(pairs)

    summary_rows = []

    for idx, (old_file, new_file, pair_name) in enumerate(pairs, 1):
        print(f"\n{'='*70}")
        print(f"  [{idx}/{total_pairs}] {pair_name}")
        print(f"  Old: {old_file}")
        print(f"  New: {new_file}")
        print(f"{'='*70}")

        try:
            all_stats = compare_excel(old_file, new_file,
                                      os.path.join(output_dir, f"diff_{pair_name}.txt"))

            # Aggregate statistics for each comparison pair
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
                if '(Added)' in sheet_name:
                    sheets_new += 1
                if '(Deleted)' in sheet_name:
                    sheets_del += 1

            has_changes = (total_add + total_del + total_mod) > 0 or sheets_new > 0 or sheets_del > 0

            summary_rows.append({
                'File Name': pair_name,
                'Status': 'Has Changes' if has_changes else 'No Changes',
                'Total Sheets': len(all_stats),
                'Added Sheets': sheets_new,
                'Deleted Sheets': sheets_del,
                'Total Rows': total_rows,
                'Added Rows': total_add,
                'Deleted Rows': total_del,
                'Modified Rows': total_mod,
                'Unchanged': total_unch,
            })

        except Exception as e:
            print(f"  Compare failed: {e}")
            import traceback
            traceback.print_exc()
            summary_rows.append({
                'File Name': pair_name,
                'Status': 'Compare Failed',
                'Total Sheets': 0,
                'Added Sheets': 0,
                'Deleted Sheets': 0,
                'Total Rows': 0,
                'Added Rows': 0,
                'Deleted Rows': 0,
                'Modified Rows': 0,
                'Unchanged': 0,
            })

    # Generate summary report
    df = pd.DataFrame(summary_rows)
    summary_path = os.path.join(output_dir, 'batch_diff_summary.xlsx')
    df.to_excel(summary_path, index=False)
    print(f"\n{'='*70}")
    print(f"  All done! Processed {total_pairs} pair(s)")
    print(f"  Summary report: {summary_path}")
    print(f"  Output directory: {output_dir}")
    print(f"{'='*70}")


def main():
    parser = argparse.ArgumentParser(description='Batch compare Excel file differences')
    parser.add_argument('list_file', nargs='?',
                        help='CSV file path with columns old_file,new_file[,name]')
    parser.add_argument('--output', '-o', default='./output',
                        help='Output directory (default ./output)')

    args = parser.parse_args()

    if args.list_file:
        csv_path = args.list_file
    else:
        default_csv = 'diff_list.csv'
        if os.path.exists(default_csv):
            csv_path = default_csv
        else:
            print("Usage: python batch_excel_diff_en.py diff_list.csv")
            print("")
            print("CSV format (first row is header):")
            print("  old_file,new_file,name")
            print("  ./dir/fileA_v1.xlsx,./dir/fileA_v2.xlsx,Report A")
            print("  ./dir/fileB_v1.xlsx,./dir/fileB_v2.xlsx,Report B")
            sys.exit(1)

    print(f"Reading comparison list: {csv_path}")
    pairs = read_pair_list(csv_path)

    if not pairs:
        print("No valid comparison pairs")
        sys.exit(1)

    print(f"Total {len(pairs)} pair(s):")
    for old_f, new_f, name in pairs:
        print(f"  {name}: {os.path.basename(old_f)} -> {os.path.basename(new_f)}")

    batch_compare(pairs, args.output)


if __name__ == '__main__':
    main()
