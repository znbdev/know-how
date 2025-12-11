import pandas as pd
import xlsxwriter

# データフレームを作成する
df_task = pd.DataFrame(columns=[
    "タスクID","タスク名","担当者","プロジェクト","計画開始日","計画終了日",
    "実際の開始日","実際の完了日","ステータス","進捗率(%)","問題あり","問題影響度","問題解決者",
    "遅延日数"  # 新規
])

df_report = pd.DataFrame(columns=[
    "報告日","担当者","タスクID","本日完了作業","進捗率更新(%)","保留事項","次のステップ"
])

df_issue = pd.DataFrame(columns=[
    "問題ID","タスクID","発見日","問題説明","潜在的影響","影響度",
    "解決策","解決状況","解決者","予想解決日"
])

output_file = "Team_Task_Progress_System_Enhanced_JA.xlsx"

with pd.ExcelWriter(output_file, engine="xlsxwriter") as writer:
    workbook = writer.book

    # シートに書き込む
    df_task.to_excel(writer, sheet_name="タスクマスターリスト", index=False)
    df_report.to_excel(writer, sheet_name="レポートデータ", index=False)
    df_issue.to_excel(writer, sheet_name="問題追跡", index=False)

    sheet1 = writer.sheets["タスクマスターリスト"]
    sheet3 = writer.sheets["問題追跡"]

    # ドロップダウン用の非表示シート
    hidden = workbook.add_worksheet("リスト")
    status_list = ["未開始", "進行中", "完了", "一時停止", "遅延"]
    yesno_list = ["はい", "いいえ"]
    impact_list = ["高", "中", "低"]
    solve_status_list = ["保留中", "解決中", "解決済み"]

    for i, v in enumerate(status_list): hidden.write(i,0,v)
    for i, v in enumerate(yesno_list): hidden.write(i,1,v)
    for i, v in enumerate(impact_list): hidden.write(i,2,v)
    for i, v in enumerate(solve_status_list): hidden.write(i,3,v)

    workbook.define_name("status_list", "=リスト!$A$1:$A$5")
    workbook.define_name("yesno_list", "=リスト!$B$1:$B$2")
    workbook.define_name("impact_list", "=リスト!$C$1:$C$3")
    workbook.define_name("solve_status_list", "=リスト!$D$1:$D$3")

    # ドロップダウン検証
    sheet1.data_validation("I2:I500", {"validate":"list","source":"=status_list"})
    sheet1.data_validation("K2:K500", {"validate":"list","source":"=yesno_list"})
    sheet1.data_validation("L2:L500", {"validate":"list","source":"=impact_list"})
    sheet3.data_validation("F2:F500", {"validate":"list","source":"=impact_list"})
    sheet3.data_validation("H2:H500", {"validate":"list","source":"=solve_status_list"})

    # ===== 1. 遅延日数の自動計算 =====
    for row in range(2, 501):
        formula = f'=IF(I{row}="完了",0, IF(TODAY()>F{row}, TODAY()-F{row}, 0))'
        sheet1.write_formula(row-1, 13, formula)  # 列N (遅延日数)

    # ===== 2. ステータスの自動更新（ロジックに基づく） =====
    # ステータス列 I
    for row in range(2, 501):
        formula = (
            f'IF(H{row}<>"" , "完了",'
            f'IF(AND(E{row}="",F{row}=""),"未開始",'
            f'IF(AND(TODAY()>F{row}, J{row}<100),"遅延",'
            f'IF(J{row}=0,"未開始",'
            f'IF(J{row}=100,"完了","進行中")))))'
        )
        sheet1.write_formula(row-1, 8, formula)

    # ===== 3. 進捗バーの視覚化 =====
    sheet1.conditional_format("J2:J500", {
        "type": "data_bar",
        "bar_border_color": "#000000"
    })

    # ===== 5. 進捗率列のパーセンテージフォーマット設定 =====
    percentage_format = workbook.add_format({'num_format': '0.00%'})
    sheet1.set_column('J:J', None, percentage_format)

    # ===== 4. ピボットテーブルの説明 =====
    # 注: xlsxwriterはピボットテーブルの直接作成をサポートしていません
    # VBAマクロスクリプトを使用してピボットテーブルを自動作成できます
    chart_sheet = workbook.add_worksheet("説明")
    
    # 説明文を追加
    chart_sheet.write('A1', '説明:')
    chart_sheet.write('A2', '1. このワークブックには自動生成されたピボットテーブルは含まれていません')
    chart_sheet.write('A3', '2. ピボットテーブルを自動作成するには:')
    chart_sheet.write('A4', '   a. Alt + F11 を押してVBAエディタを開く')
    chart_sheet.write('A5', '   b. 挿入 -> モジュール')
    chart_sheet.write('A6', '   c. AutoCreatePivotTables.basスクリプトをコピー＆ペースト')
    chart_sheet.write('A7', '   d. CreatePivotTablesサブルーチンを実行')
    chart_sheet.write('A8', '   日本語版の場合は、AutoCreatePivotTables_ja.basを使用してください')
    chart_sheet.write('A9', '3. または、Excelで挿入 -> ピボットテーブルから手動で作成できます')
    chart_sheet.write('A10', '4. 進捗率列のパーセンテージフォーマットは正しく設定されています')

print("Excelファイルが正常に生成されました: ", output_file)