Attribute VB_Name = "AutoCreatePivotTables"
Sub 创建数据透视表()
    Dim ws As Worksheet
    Dim ptCache As PivotCache
    Dim ptTable As PivotTable
    Dim ptSheet As Worksheet
    Dim lastRow As Long
    
    ' 检查是否已存在透视表工作表，如果存在则删除
    On Error Resume Next
    Application.DisplayAlerts = False
    Sheets("透视表汇总").Delete
    Application.DisplayAlerts = True
    On Error GoTo 0
    
    ' 创建新的透视表工作表
    Set ptSheet = Worksheets.Add
    ptSheet.Name = "透视表汇总"
    
    ' 获取任务主列表的最后一行
    Set ws = Sheets("Task Master List")
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    
    ' 检查是否有数据
    If lastRow < 2 Then
        MsgBox "任务主列表中没有数据，无法创建透视表。", vbExclamation
        Exit Sub
    End If
    
    ' 创建第一个透视表 - 按项目统计任务数
    Set ptCache = ActiveWorkbook.PivotCaches.Create( _
        SourceType:=xlDatabase, _
        SourceData:=ws.Range("A1:N" & lastRow))
        
    Set ptTable = ptCache.CreatePivotTable( _
        TableDestination:=ptSheet.Range("A1"), _
        TableName:="按项目统计")
        
    With ptTable
        ' 设置行字段为项目
        .PivotFields("Project").Orientation = xlRowField
        .PivotFields("Project").Position = 1
        
        ' 设置数据字段为任务计数
        .AddDataField .PivotFields("Task ID"), "任务数", xlCount
    End With
    
    ' 创建第二个透视表 - 按状态统计任务数
    Set ptCache = ActiveWorkbook.PivotCaches.Create( _
        SourceType:=xlDatabase, _
        SourceData:=ws.Range("A1:N" & lastRow))
        
    Set ptTable = ptCache.CreatePivotTable( _
        TableDestination:=ptSheet.Range("A15"), _
        TableName:="按状态统计")
        
    With ptTable
        ' 设置行字段为状态
        .PivotFields("Status").Orientation = xlRowField
        .PivotFields("Status").Position = 1
        
        ' 设置数据字段为任务计数
        .AddDataField .PivotFields("Task ID"), "任务数", xlCount
    End With
    
    ' 创建第三个透视表 - 按负责人统计任务数
    Set ptCache = ActiveWorkbook.PivotCaches.Create( _
        SourceType:=xlDatabase, _
        SourceData:=ws.Range("A1:N" & lastRow))
        
    Set ptTable = ptCache.CreatePivotTable( _
        TableDestination:=ptSheet.Range("E1"), _
        TableName:="按负责人统计")
        
    With ptTable
        ' 设置行字段为负责人
        .PivotFields("Owner").Orientation = xlRowField
        .PivotFields("Owner").Position = 1
        
        ' 设置数据字段为任务计数
        .AddDataField .PivotFields("Task ID"), "任务数", xlCount
    End With
    
    ' 创建图表
    创建透视表图表 ptSheet
    
    MsgBox "透视表和图表已成功创建！", vbInformation
End Sub

Sub 创建透视表图表(ptSheet As Worksheet)
    Dim chartObj As ChartObject
    
    ' 创建项目任务统计图表
    Set chartObj = ptSheet.ChartObjects.Add(Left:=300, Top:=50, Width:=300, Height:=200)
    With chartObj.Chart
        .SetSourceData ptSheet.Range("A1:B10")
        .ChartType = xlColumnClustered
        .HasTitle = True
        .ChartTitle.Text = "项目任务统计"
    End With
    
    ' 创建状态任务统计图表
    Set chartObj = ptSheet.ChartObjects.Add(Left:=300, Top:=300, Width:=300, Height:=200)
    With chartObj.Chart
        .SetSourceData ptSheet.Range("A15:B25")
        .ChartType = xlPie
        .HasTitle = True
        .ChartTitle.Text = "状态任务统计"
    End With
End Sub

' 自动运行函数 - 当工作簿打开时自动创建透视表
Private Sub Workbook_Open()
    ' 这个函数应该放在ThisWorkbook模块中
    ' 为了方便，我们在这里提供代码，但实际使用时需要将其复制到ThisWorkbook模块
    ' Call 创建数据透视表
End Sub