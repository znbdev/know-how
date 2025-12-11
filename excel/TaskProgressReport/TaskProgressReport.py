import pandas as pd
import xlsxwriter

# Create DataFrames
df_task = pd.DataFrame(columns=[
    "Task ID","Task Name","Owner","Project","Planned Start Date","Planned End Date",
    "Actual Start Date","Actual Completion Date","Status","Progress(%)","Has Issue","Issue Impact Level","Issue Resolver",
    "Overdue Days"  # NEW
])

df_report = pd.DataFrame(columns=[
    "Report Date","Owner","Task ID","Work Completed Today","Progress Update(%)","Pending Items","Next Steps"
])

df_issue = pd.DataFrame(columns=[
    "Issue ID","Task ID","Discovery Date","Issue Description","Potential Impact","Impact Level",
    "Solution","Resolution Status","Resolver","Expected Resolution Date"
])

output_file = "Team_Task_Progress_System_Enhanced.xlsx"

with pd.ExcelWriter(output_file, engine="xlsxwriter") as writer:
    workbook = writer.book

    # Write sheets
    df_task.to_excel(writer, sheet_name="Task Master List", index=False)
    df_report.to_excel(writer, sheet_name="Report Data", index=False)
    df_issue.to_excel(writer, sheet_name="Issue Tracking", index=False)

    sheet1 = writer.sheets["Task Master List"]
    sheet3 = writer.sheets["Issue Tracking"]

    # Hidden sheet for dropdowns
    hidden = workbook.add_worksheet("lists")
    status_list = ["Not Started", "In Progress", "Completed", "Paused", "Overdue"]
    yesno_list = ["Yes", "No"]
    impact_list = ["High", "Medium", "Low"]
    solve_status_list = ["Pending", "In Progress", "Resolved"]

    for i, v in enumerate(status_list): hidden.write(i,0,v)
    for i, v in enumerate(yesno_list): hidden.write(i,1,v)
    for i, v in enumerate(impact_list): hidden.write(i,2,v)
    for i, v in enumerate(solve_status_list): hidden.write(i,3,v)

    workbook.define_name("status_list", "=lists!$A$1:$A$5")
    workbook.define_name("yesno_list", "=lists!$B$1:$B$2")
    workbook.define_name("impact_list", "=lists!$C$1:$C$3")
    workbook.define_name("solve_status_list", "=lists!$D$1:$D$3")

    # Dropdown validations
    sheet1.data_validation("I2:I500", {"validate":"list","source":"=status_list"})
    sheet1.data_validation("K2:K500", {"validate":"list","source":"=yesno_list"})
    sheet1.data_validation("L2:L500", {"validate":"list","source":"=impact_list"})
    sheet3.data_validation("F2:F500", {"validate":"list","source":"=impact_list"})
    sheet3.data_validation("H2:H500", {"validate":"list","source":"=solve_status_list"})

    # ===== 1. Auto-calculate overdue days =====
    for row in range(2, 501):
        formula = f'=IF(I{row}="Completed",0, IF(TODAY()>F{row}, TODAY()-F{row}, 0))'
        sheet1.write_formula(row-1, 13, formula)  # Column N (Overdue Days)

    # ===== 2. Auto-update status (based on logic) =====
    # Status column I
    for row in range(2, 501):
        formula = (
            f'=IF(H{row}<>"" , "Completed",'
            f'IF(AND(E{row}="",F{row}=""),"Not Started",'
            f'IF(AND(TODAY()>F{row}, J{row}<100),"Overdue",'
            f'IF(J{row}=0,"Not Started",'
            f'IF(J{row}=100,"Completed","In Progress")))))'
        )
        sheet1.write_formula(row-1, 8, formula)

    # ===== 3. Progress bar visualization =====
    sheet1.conditional_format("J2:J500", {
        "type": "data_bar",
        "bar_border_color": "#000000"
    })

    # ===== 5. Set percentage format for progress column =====
    percentage_format = workbook.add_format({'num_format': '0.00%'})
    sheet1.set_column('J:J', None, percentage_format)

    # ===== 4. Instructions for Pivot Tables =====
    # Note: xlsxwriter does not support creating pivot tables directly
    # VBA macro script is provided to automatically create pivot tables
    chart_sheet = workbook.add_worksheet("Instructions")
    
    # Add descriptive text
    chart_sheet.write('A1', 'Instructions:')
    chart_sheet.write('A2', '1. This workbook does not contain auto-generated pivot tables')
    chart_sheet.write('A3', '2. To automatically create pivot tables:')
    chart_sheet.write('A4', '   a. Press Alt + F11 to open VBA editor')
    chart_sheet.write('A5', '   b. Insert -> Module')
    chart_sheet.write('A6', '   c. Copy and paste the AutoCreatePivotTables.bas script')
    chart_sheet.write('A7', '   d. Run the CreatePivotTables subroutine')
    chart_sheet.write('A8', '   For Chinese version, use AutoCreatePivotTables_zh.bas')
    chart_sheet.write('A9', '3. Alternatively, pivot tables can be manually created using Insert -> PivotTable in Excel')
    chart_sheet.write('A10', '4. Percentage format has been correctly set in the progress column')

print("Excel file successfully generated: ", output_file)
