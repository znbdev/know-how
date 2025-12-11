Sub CreatePivotChartsWithDebug()
    ' Debug version to test chart creation separately
    Dim ws As Worksheet
    Dim chartObj As ChartObject
    
    On Error Resume Next
    Set ws = Sheets("Pivot Summary")
    If ws Is Nothing Then
        MsgBox "Pivot Summary worksheet not found. Please create pivot tables first.", vbExclamation
        Exit Sub
    End If
    
    ' Test creating a simple chart
    Set chartObj = ws.ChartObjects.Add(Left:=100, Top:=100, Width:=300, Height:=200)
    With chartObj.Chart
        .ChartType = xlColumnClustered
        .HasTitle = True
        .ChartTitle.Text = "Test Chart"
        .HasLegend = True
    End With
    
    If Err.Number = 0 Then
        MsgBox "Chart creation test successful!", vbInformation
    Else
        MsgBox "Chart creation test failed: " & Err.Description, vbCritical
    End If
End Sub

Sub RepairPivotCharts()
    ' Function to repair or recreate charts if they are not working properly
    Dim ws As Worksheet
    Dim chartObj As ChartObject
    Dim ptTable As PivotTable
    Dim i As Integer
    
    On Error Resume Next
    Set ws = Sheets("Pivot Summary")
    If ws Is Nothing Then
        MsgBox "Pivot Summary worksheet not found.", vbExclamation
        Exit Sub
    End If
    
    ' Delete existing charts
    For i = ws.ChartObjects.Count To 1 Step -1
        ws.ChartObjects(i).Delete
    Next i
    
    ' Recreate charts with proper data sources
    If ws.PivotTables.Count >= 3 Then
        ' Project chart
        Set ptTable = ws.PivotTables("PivotByProject")
        If Not ptTable Is Nothing Then
            Set chartObj = ws.ChartObjects.Add(Left:=300, Top:=50, Width:=300, Height:=200)
            With chartObj.Chart
                .SetSourceData ptTable.TableRange1
                .ChartType = xlColumnClustered
                .HasTitle = True
                .ChartTitle.Text = "Project Task Statistics"
                .HasLegend = True
            End With
        End If
        
        ' Status chart
        Set ptTable = ws.PivotTables("PivotByStatus")
        If Not ptTable Is Nothing Then
            Set chartObj = ws.ChartObjects.Add(Left:=300, Top:=300, Width:=300, Height:=200)
            With chartObj.Chart
                .SetSourceData ptTable.TableRange1
                .ChartType = xlPie
                .HasTitle = True
                .ChartTitle.Text = "Status Task Statistics"
                .HasLegend = True
            End With
        End If
        
        ' Owner chart
        Set ptTable = ws.PivotTables("PivotByOwner")
        If Not ptTable Is Nothing Then
            Set chartObj = ws.ChartObjects.Add(Left:=600, Top:=50, Width:=300, Height:=200)
            With chartObj.Chart
                .SetSourceData ptTable.TableRange1
                .ChartType = xlBarClustered
                .HasTitle = True
                .ChartTitle.Text = "Tasks by Owner"
                .HasLegend = True
            End With
        End If
        
        MsgBox "Charts have been repaired successfully!", vbInformation
    Else
        MsgBox "Not enough pivot tables found. Please create pivot tables first.", vbExclamation
    End If
End Sub