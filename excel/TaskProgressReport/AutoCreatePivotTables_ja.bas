Attribute VB_Name = "AutoCreatePivotTables"
Sub ピボットテーブル作成()
    Dim ws As Worksheet
    Dim ptCache As PivotCache
    Dim ptTable As PivotTable
    Dim ptSheet As Worksheet
    Dim lastRow As Long
    Dim dataRange As String
    
    On Error GoTo ErrorHandler
    
    ' ピボットテーブルシートが既に存在する場合、削除する
    On Error Resume Next
    Application.DisplayAlerts = False
    Sheets("ピボットサマリー").Delete
    Application.DisplayAlerts = True
    On Error GoTo ErrorHandler
    
    ' 新しいピボットテーブルシートを作成
    Set ptSheet = Worksheets.Add
    ptSheet.Name = "ピボットサマリー"
    
    ' タスクマスターリストシートを取得
    On Error Resume Next
    Set ws = Sheets("タスクマスターリスト")
    On Error GoTo ErrorHandler
    
    If ws Is Nothing Then
        MsgBox "「タスクマスターリスト」シートが見つかりません。シート名を確認してください。", vbCritical
        Exit Sub
    End If
    
    ' データの最終行を取得
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    
    ' データがあるか確認
    If lastRow < 2 Then
        MsgBox "タスクマスターリストにデータがないため、ピボットテーブルを作成できません。", vbExclamation
        Exit Sub
    End If
    
    ' データ範囲を定義
    dataRange = "タスクマスターリスト!R1C1:R" & lastRow & "C14"  ' A1:N 14列分
    
    ' 最初のピボットテーブルを作成 - プロジェクト別タスク数
    On Error Resume Next
    Set ptCache = ActiveWorkbook.PivotCaches.Create( _
        SourceType:=xlDatabase, _
        SourceData:=dataRange)
    
    If ptCache Is Nothing Then
        ' 代替方法を試す
        Set ptCache = ActiveWorkbook.PivotCaches.Create( _
            SourceType:=xlWorksheet, _
            SourceData:=dataRange)
    End If
    
    If ptCache Is Nothing Then
        MsgBox "ピボットキャッシュの作成に失敗しました。データソースを確認してください。", vbCritical
        Exit Sub
    End If
    
    On Error GoTo ErrorHandler
    Set ptTable = ptCache.CreatePivotTable( _
        TableDestination:=ptSheet.Range("A1"), _
        TableName:="プロジェクト別")
        
    If ptTable Is Nothing Then
        MsgBox "ピボットテーブルの作成に失敗しました。Excelの設定を確認してください。", vbCritical
        Exit Sub
    End If
    
    With ptTable
        On Error Resume Next
        ' 行フィールドをプロジェクトに設定
        .PivotFields("プロジェクト").Orientation = xlRowField
        .PivotFields("プロジェクト").Position = 1
        
        ' データフィールドをタスク数に設定
        .AddDataField .PivotFields("タスクID"), "タスク数", xlCount
        On Error GoTo ErrorHandler
    End With
    
    ' 2番目のピボットテーブルを作成 - ステータス別タスク数
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
        TableName:="ステータス別")
        
    With ptTable
        On Error Resume Next
        ' 行フィールドをステータスに設定
        .PivotFields("ステータス").Orientation = xlRowField
        .PivotFields("ステータス").Position = 1
        
        ' データフィールドをタスク数に設定
        .AddDataField .PivotFields("タスクID"), "タスク数", xlCount
        On Error GoTo ErrorHandler
    End With
    
    ' 3番目のピボットテーブルを作成 - 担当者別タスク数
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
        TableName:="担当者別")
        
    With ptTable
        On Error Resume Next
        ' 行フィールドを担当者に設定
        .PivotFields("担当者").Orientation = xlRowField
        .PivotFields("担当者").Position = 1
        
        ' データフィールドをタスク数に設定
        .AddDataField .PivotFields("タスクID"), "タスク数", xlCount
        On Error GoTo ErrorHandler
    End With
    
    ' チャートを作成
    ピボットチャート作成 ptSheet
    
    MsgBox "ピボットテーブルとチャートが正常に作成されました！", vbInformation
    Exit Sub
    
ErrorHandler:
    MsgBox "エラーが発生しました: " & Err.Description & vbCrLf & _
           "エラー番号: " & Err.Number & vbCrLf & _
           "データを確認して再度お試しください。", vbCritical
End Sub

Sub ピボットチャート作成(ptSheet As Worksheet)
    On Error GoTo ChartErrorHandler
    
    Dim chartObj As ChartObject
    
    ' プロジェクト別タスク統計チャート
    Set chartObj = ptSheet.ChartObjects.Add(Left:=300, Top:=50, Width:=300, Height:=200)
    With chartObj.Chart
        .SetSourceData ptSheet.Range("A1:B10")
        .ChartType = xlColumnClustered
        .HasTitle = True
        .ChartTitle.Text = "プロジェクト別タスク統計"
    End With
    
    ' ステータス別タスク統計チャート
    Set chartObj = ptSheet.ChartObjects.Add(Left:=300, Top:=300, Width:=300, Height:=200)
    With chartObj.Chart
        .SetSourceData ptSheet.Range("A15:B25")
        .ChartType = xlPie
        .HasTitle = True
        .ChartTitle.Text = "ステータス別タスク統計"
    End With
    
    Exit Sub
    
ChartErrorHandler:
    MsgBox "警告: チャートを作成できませんでした。必要であれば手動で作成してください。", vbExclamation
End Sub

' 自動実行関数 - ワークブックを開いた時にピボットテーブルを自動作成
Private Sub Workbook_Open()
    ' この関数はThisWorkbookモジュールに配置する必要があります
    ' 便宜上ここにコードを提供しますが、実際にはThisWorkbookモジュールにコピーする必要があります
    ' Call ピボットテーブル作成
End Sub