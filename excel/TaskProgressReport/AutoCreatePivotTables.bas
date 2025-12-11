Sub CreatePivotTables()
    Dim ws As Worksheet
    Dim ptCache As PivotCache
    Dim ptTable As PivotTable
    Dim ptSheet As Worksheet
    Dim lastRow As Long
    Dim dataRange As String
    
    On Error GoTo ErrorHandler
    
    ' Check if pivot table worksheet already exists, delete if it does
    On Error Resume Next
    Application.DisplayAlerts = False
    Sheets("Pivot Summary").Delete
    Application.DisplayAlerts = True
    On Error GoTo ErrorHandler
    
    ' Create a new pivot table worksheet
    Set ptSheet = Worksheets.Add
    ptSheet.Name = "Pivot Summary"
    
    ' Get Task Master List worksheet
    On Error Resume Next
    Set ws = Sheets("Task Master List")
    On Error GoTo ErrorHandler
    
    If ws Is Nothing Then
        MsgBox "Cannot find 'Task Master List' worksheet. Please check the worksheet name.", vbCritical
        Exit Sub
    End If
    
    ' Get the last row and column of data
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    
    ' Check if there is data
    If lastRow < 2 Then
        MsgBox "No data in Task Master List, cannot create pivot table.", vbExclamation
        Exit Sub
    End If
    
    ' Define data range
    dataRange = "Task Master List!R1C1:R" & lastRow & "C14"  ' A1:N for 14 columns
    
    ' Create the first pivot table - Count tasks by project
    On Error Resume Next
    Set ptCache = ActiveWorkbook.PivotCaches.Create( _
        SourceType:=xlDatabase, _
        SourceData:=dataRange)
    
    If ptCache Is Nothing Then
        ' Try alternative method
        Set ptCache = ActiveWorkbook.PivotCaches.Create( _
            SourceType:=xlWorksheet, _
            SourceData:=dataRange)
    End If
    
    If ptCache Is Nothing Then
        MsgBox "Failed to create pivot cache. Please check the data source.", vbCritical
        Exit Sub
    End If
    
    On Error GoTo ErrorHandler
    Set ptTable = ptCache.CreatePivotTable( _
        TableDestination:=ptSheet.Range("A1"), _
        TableName:="PivotByProject")
        
    If ptTable Is Nothing Then
        MsgBox "Failed to create pivot table. Please check Excel settings.", vbCritical
        Exit Sub
    End If
    
    With ptTable
        On Error Resume Next
        ' Set row field to project
        .PivotFields("Project").Orientation = xlRowField
        .PivotFields("Project").Position = 1
        
        ' Set data field to task count
        .AddDataField .PivotFields("Task ID"), "Count of Tasks", xlCount
        On Error GoTo ErrorHandler
    End With
    
    ' Create the second pivot table - Count tasks by status
    On Error Resume Next
    Set ptCache = ActiveWorkbook.PivotCaches.Create( _
        SourceType:=xlDatabase, _
        SourceData:=dataRange)
    
    If ptCache Is Nothing Then
        Set ptCache = ActiveWorkbook.PivotCaches.Create( _
            SourceType:=xlWorksheet, _
            SourceData:=dataRange)
    End If
    
    On Error GoTo ErrorHandler
    Set ptTable = ptCache.CreatePivotTable( _
        TableDestination:=ptSheet.Range("A15"), _
        TableName:="PivotByStatus")
        
    With ptTable
        On Error Resume Next
        ' Set row field to status
        .PivotFields("Status").Orientation = xlRowField
        .PivotFields("Status").Position = 1
        
        ' Set data field to task count
        .AddDataField .PivotFields("Task ID"), "Count of Tasks", xlCount
        On Error GoTo ErrorHandler
    End With
    
    ' Create the third pivot table - Count tasks by owner
    On Error Resume Next
    Set ptCache = ActiveWorkbook.PivotCaches.Create( _
        SourceType:=xlDatabase, _
        SourceData:=dataRange)
    
    If ptCache Is Nothing Then
        Set ptCache = ActiveWorkbook.PivotCaches.Create( _
            SourceType:=xlWorksheet, _
            SourceData:=dataRange)
    End If
    
    On Error GoTo ErrorHandler
    Set ptTable = ptCache.CreatePivotTable( _
        TableDestination:=ptSheet.Range("E1"), _
        TableName:="PivotByOwner")
        
    With ptTable
        On Error Resume Next
        ' Set row field to owner
        .PivotFields("Owner").Orientation = xlRowField
        .PivotFields("Owner").Position = 1
        
        ' Set data field to task count
        .AddDataField .PivotFields("Task ID"), "Count of Tasks", xlCount
        On Error GoTo ErrorHandler
    End With
    
    ' Get Report Data worksheet
    On Error Resume Next
    Set ws = Sheets("Report Data")
    On Error GoTo ErrorHandler
    
    If Not ws Is Nothing Then
        ' Get the last row and column of data
        lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
        
        ' Check if there is data
        If lastRow >= 2 Then
            ' Define data range
            dataRange = "Report Data!R1C1:R" & lastRow & "C7"  ' A1:G for 7 columns
            
            ' Create the fourth pivot table - Count tasks by owner in Report Data
            On Error Resume Next
            Set ptCache = ActiveWorkbook.PivotCaches.Create( _
                SourceType:=xlDatabase, _
                SourceData:=dataRange)
            
            If ptCache Is Nothing Then
                Set ptCache = ActiveWorkbook.PivotCaches.Create( _
                    SourceType:=xlWorksheet, _
                    SourceData:=dataRange)
            End If
            
            On Error GoTo ErrorHandler
            Set ptTable = ptCache.CreatePivotTable( _
                TableDestination:=ptSheet.Range("E15"), _
                TableName:="PivotByReportOwner")
                
            With ptTable
                On Error Resume Next
                ' Set row field to owner
                .PivotFields("Owner").Orientation = xlRowField
                .PivotFields("Owner").Position = 1
                
                ' Set data field to task count
                .AddDataField .PivotFields("Task ID"), "Count of Tasks", xlCount
                On Error GoTo ErrorHandler
            End With
        End If
    End If
    
    ' Create charts
    On Error Resume Next
    CreatePivotCharts ptSheet
    If Err.Number <> 0 Then
        MsgBox "Pivot tables created successfully, but charts creation had issues. " & _
               "You can create charts manually from the pivot tables.", vbExclamation
    Else
        MsgBox "Pivot tables and charts have been successfully created!", vbInformation
    End If
    On Error GoTo ErrorHandler
    Exit Sub
    
ErrorHandler:
    MsgBox "An error occurred: " & Err.Description & vbCrLf & _
           "Error number: " & Err.Number & vbCrLf & _
           "Please check your data and try again.", vbCritical
End Sub

Sub CreatePivotCharts(ptSheet As Worksheet)
    On Error GoTo ChartErrorHandler
    
    Dim chartObj As ChartObject
    Dim ptTable As PivotTable
    Dim dataRange As Range
    
    ' Create project task statistics chart
    On Error Resume Next
    Set ptTable = ptSheet.PivotTables("PivotByProject")
    If Not ptTable Is Nothing Then
        Set dataRange = ptTable.TableRange1
        Set chartObj = ptSheet.ChartObjects.Add(Left:=300, Top:=50, Width:=300, Height:=200)
        With chartObj.Chart
            .SetSourceData dataRange
            .ChartType = xlColumnClustered
            .HasTitle = True
            .ChartTitle.Text = "Project Task Statistics"
            .HasLegend = True
        End With
    End If
    
    ' Create status task statistics chart
    On Error Resume Next
    Set ptTable = ptSheet.PivotTables("PivotByStatus")
    If Not ptTable Is Nothing Then
        Set dataRange = ptTable.TableRange1
        Set chartObj = ptSheet.ChartObjects.Add(Left:=300, Top:=300, Width:=300, Height:=200)
        With chartObj.Chart
            .SetSourceData dataRange
            .ChartType = xlPie
            .HasTitle = True
            .ChartTitle.Text = "Status Task Statistics"
            .HasLegend = True
        End With
    End If
    
    ' Create owner task statistics chart
    On Error Resume Next
    Set ptTable = ptSheet.PivotTables("PivotByOwner")
    If Not ptTable Is Nothing Then
        Set dataRange = ptTable.TableRange1
        Set chartObj = ptSheet.ChartObjects.Add(Left:=600, Top:=50, Width:=300, Height:=200)
        With chartObj.Chart
            .SetSourceData dataRange
            .ChartType = xlBarClustered
            .HasTitle = True
            .ChartTitle.Text = "Tasks by Owner"
            .HasLegend = True
        End With
    End If
    
    ' Create owner task statistics chart from Report Data
    On Error Resume Next
    Set ptTable = ptSheet.PivotTables("PivotByReportOwner")
    If Not ptTable Is Nothing Then
        Set dataRange = ptTable.TableRange1
        Set chartObj = ptSheet.ChartObjects.Add(Left:=600, Top:=300, Width:=300, Height:=200)
        With chartObj.Chart
            .SetSourceData dataRange
            .ChartType = xlBarClustered
            .HasTitle = True
            .ChartTitle.Text = "Tasks by Owner (Report Data)"
            .HasLegend = True
        End With
    End If
    
    On Error GoTo 0
    Exit Sub
    
ChartErrorHandler:
    MsgBox "Warning: Could not create charts. Error: " & Err.Description & vbCrLf & _
           "You can create them manually from the pivot tables if needed.", vbExclamation
End Sub

' Auto-run function - Automatically create pivot tables when the workbook opens
Private Sub Workbook_Open()
    ' This function should be placed in the ThisWorkbook module
    ' For convenience, we provide the code here, but in practice it needs to be copied to the ThisWorkbook module
    ' Call CreatePivotTables
End Sub