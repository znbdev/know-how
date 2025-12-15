''''''''''''''''''''''''''''''''''''''''''''''''''
' FindShapeText
''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit
Sub FindShapeText()
'---------------------------------------------------------------
' Function: Searches all Excel files in the same folder
'           for a user-specified keyword.
'           Search scope includes cell values and shape text.
'           Uses fuzzy matching (LookAt:=xlPart).
'           Results include file name, sheet name, location type, location detail, and found text.
'---------------------------------------------------------------

' Variable Declarations
Dim SearchKeyword As String
Dim ReportSheet As Worksheet
Dim folderPath As String
Dim fileName As String
Dim wb As Workbook
Dim ws As Worksheet
Dim nextRow As Long
Dim cellMatch As Range
Dim shp As Shape
Dim shapeText As String
Dim firstAddress As String
Dim fileCount As Long
Dim totalMatches As Long

' 1. Get Search Keyword from User
On Error Resume Next
SearchKeyword = Application.InputBox( _
    Prompt:="Enter the keyword to search for (fuzzy match):", _
    Title:="Keyword Search in All Excel Files", _
    Type:=2)
On Error GoTo 0 ' Resume normal error handling

' Exit if user cancels or enters no text
If SearchKeyword = "False" Or SearchKeyword = "" Then
    MsgBox "Search cancelled.", vbInformation
    Exit Sub
End If

' 2. Set the Report Worksheet (the sheet running the macro)
Set ReportSheet = ActiveSheet

' 3. Get the folder path
folderPath = ThisWorkbook.Path
If Right(folderPath, 1) <> "\" Then
    folderPath = folderPath & "\"
End If

' 4. Clear previous results and set headers
ReportSheet.Cells.Clear
ReportSheet.Range("A1:E1").Value = Array("File Name", "Sheet Name", "Location Type", "Location Detail", "Found Text")
ReportSheet.Range("A1:E1").Font.Bold = True
nextRow = 2 ' Start reporting results from row 2
fileCount = 0
totalMatches = 0

Application.ScreenUpdating = False
Application.DisplayAlerts = False

' 5. Start the main file loop
fileName = Dir(folderPath & "*.xls*")

Do While fileName <> ""
    ' Skip the current workbook (the one running the macro)
    If fileName <> ThisWorkbook.Name Then
        fileCount = fileCount + 1
        
        ' Open the workbook silently
        On Error Resume Next
        Set wb = Workbooks.Open(folderPath & fileName, ReadOnly:=True, UpdateLinks:=0)
        
        If Not wb Is Nothing Then
            ' Search all worksheets in this workbook
            For Each ws In wb.Worksheets
                ' --- PART A: Search CELLS for the Keyword (Fuzzy Match) ---
                
                Set cellMatch = ws.UsedRange.Find( _
                    What:=SearchKeyword, _
                    LookIn:=xlValues, _
                    LookAt:=xlPart, _
                    SearchOrder:=xlByRows, _
                    MatchCase:=False)
                
                ' If the first match is found
                If Not cellMatch Is Nothing Then
                    firstAddress = cellMatch.Address ' Record the first address
                    
                    ' Loop to find all matches
                    Do
                        ' Record the cell match
                        ReportSheet.Cells(nextRow, "A").Value = fileName
                        ReportSheet.Cells(nextRow, "B").Value = ws.Name
                        ReportSheet.Cells(nextRow, "C").Value = "Cell"
                        ReportSheet.Cells(nextRow, "D").Value = cellMatch.Address(External:=False)
                        ReportSheet.Cells(nextRow, "E").Value = cellMatch.Value
                        nextRow = nextRow + 1
                        totalMatches = totalMatches + 1
                        
                        ' Find the next match
                        Set cellMatch = ws.Cells.FindNext(cellMatch)
                        
                    ' Loop until no more matches are found or it wraps around to the start
                    Loop While Not cellMatch Is Nothing And cellMatch.Address <> firstAddress
                End If
                
                ' --- PART B: Search SHAPES for the Keyword (Fuzzy Match) ---
                
                For Each shp In ws.Shapes
                    ' Robust error handling for shapes without text frames
                    On Error Resume Next
                    ' Attempt to get shape text
                    shapeText = shp.TextFrame2.TextRange.Text
                    
                    ' Check for errors (e.g., if the shape has no text frame), clear, and skip
                    If Err.Number <> 0 Then
                        Err.Clear
                        GoTo NextShape
                    End If
                    On Error GoTo 0 ' Resume normal error handling
                    
                    ' Perform the fuzzy keyword search on the shape text (vbTextCompare is case-insensitive)
                    If InStr(1, shapeText, SearchKeyword, vbTextCompare) > 0 Then
                        ' Record the shape match
                        ReportSheet.Cells(nextRow, "A").Value = fileName
                        ReportSheet.Cells(nextRow, "B").Value = ws.Name
                        ReportSheet.Cells(nextRow, "C").Value = "Shape"
                        ReportSheet.Cells(nextRow, "D").Value = shp.Name
                        
                        ' Record the shape's content (replacing line breaks with "|")
                        ReportSheet.Cells(nextRow, "E").Value = Replace(shapeText, Chr(10), " | ")
                        nextRow = nextRow + 1
                        totalMatches = totalMatches + 1
                    End If
                    
NextShape:
                Next shp ' End of Shape loop
            Next ws ' End of Worksheet loop
            
            ' Close the workbook without saving
            wb.Close SaveChanges:=False
            Set wb = Nothing
        Else
            ' If file couldn't be opened, record it (optional)
            ReportSheet.Cells(nextRow, "A").Value = fileName
            ReportSheet.Cells(nextRow, "B").Value = "ERROR"
            ReportSheet.Cells(nextRow, "C").Value = "File"
            ReportSheet.Cells(nextRow, "D").Value = "Could not open file"
            ReportSheet.Cells(nextRow, "E").Value = "File may be corrupted or password protected"
            nextRow = nextRow + 1
        End If
        
        On Error GoTo 0 ' Resume normal error handling
    End If
    
    ' Get next file
    fileName = Dir()
Loop

' 6. Final Cleanup and Formatting
Application.ScreenUpdating = True
Application.DisplayAlerts = True

ReportSheet.Columns("A:E").AutoFit ' Autofit columns
ReportSheet.Range("A1").Select

' 7. Confirmation message
MsgBox "Keyword search complete." & vbCrLf & _
       "Files searched: " & fileCount & vbCrLf & _
       "Total matches found: " & totalMatches, vbInformation

End Sub

' Optional: Function to search only in the current workbook (original functionality)
Sub FindKeywordInCurrentWorkbook()
'---------------------------------------------------------------
' Function: Searches all worksheets (excluding the report sheet)
'           in the current workbook for a user-specified keyword.
'           Search scope includes cell values and shape text.
'           Uses fuzzy matching (LookAt:=xlPart).
'---------------------------------------------------------------

' Variable Declarations
Dim SearchKeyword As String
Dim ReportSheet As Worksheet
Dim ws As Worksheet
Dim nextRow As Long
Dim cellMatch As Range
Dim shp As Shape
Dim shapeText As String
Dim firstAddress As String

' 1. Get Search Keyword from User
On Error Resume Next
SearchKeyword = Application.InputBox( _
    Prompt:="Enter the keyword to search for (fuzzy match):", _
    Title:="Keyword Search in Current Workbook", _
    Type:=2)
On Error GoTo 0 ' Resume normal error handling

' Exit if user cancels or enters no text
If SearchKeyword = "False" Or SearchKeyword = "" Then
    MsgBox "Search cancelled.", vbInformation
    Exit Sub
End If

' 2. Set the Report Worksheet (the sheet running the macro)
Set ReportSheet = ActiveSheet

' 3. Clear previous results and set headers
ReportSheet.Cells.Clear
ReportSheet.Range("A1:D1").Value = Array("Sheet Name", "Location Type", "Location Detail", "Found Text")
ReportSheet.Range("A1:D1").Font.Bold = True
nextRow = 2 ' Start reporting results from row 2

' 4. Start the main worksheet loop
For Each ws In ActiveWorkbook.Worksheets

    ' Exclude the report sheet
    If ws.Name <> ReportSheet.Name Then

        ' --- PART A: Search CELLS for the Keyword (Fuzzy Match) ---

        ' Use Excel's built-in Find method for fast, fuzzy matching
        Set cellMatch = ws.UsedRange.Find( _
            What:=SearchKeyword, _
            LookIn:=xlValues, _
            LookAt:=xlPart, _
            SearchOrder:=xlByRows, _
            MatchCase:=False)

        ' If the first match is found
        If Not cellMatch Is Nothing Then
            firstAddress = cellMatch.Address ' Record the first address

            ' Loop to find all matches
            Do
                ' Record the cell match
                ReportSheet.Cells(nextRow, "A").Value = ws.Name
                ReportSheet.Cells(nextRow, "B").Value = "Cell"
                ReportSheet.Cells(nextRow, "C").Value = cellMatch.Address(External:=False)
                ReportSheet.Cells(nextRow, "D").Value = cellMatch.Value
                nextRow = nextRow + 1

                ' Find the next match
                Set cellMatch = ws.Cells.FindNext(cellMatch)

            ' Loop until no more matches are found or it wraps around to the start
            Loop While Not cellMatch Is Nothing And cellMatch.Address <> firstAddress
        End If

        ' --- PART B: Search SHAPES for the Keyword (Fuzzy Match) ---

        For Each shp In ws.Shapes

            ' Robust error handling for shapes without text frames
            On Error Resume Next
            ' Attempt to get shape text
            shapeText = shp.TextFrame2.TextRange.Text

            ' Check for errors (e.g., if the shape has no text frame), clear, and skip
            If Err.Number <> 0 Then
                Err.Clear
                GoTo NextShape
            End If
            On Error GoTo 0 ' Resume normal error handling

            ' Perform the fuzzy keyword search on the shape text (vbTextCompare is case-insensitive)
            If InStr(1, shapeText, SearchKeyword, vbTextCompare) > 0 Then

                ' Record the shape match
                ReportSheet.Cells(nextRow, "A").Value = ws.Name
                ReportSheet.Cells(nextRow, "B").Value = "Shape"
                ReportSheet.Cells(nextRow, "C").Value = shp.Name

                ' Record the shape's content (replacing line breaks with "|")
                ReportSheet.Cells(nextRow, "D").Value = Replace(shapeText, Chr(10), " | ")
                nextRow = nextRow + 1
            End If

NextShape:
        Next shp ' End of Shape loop
    End If
Next ws ' End of Worksheet loop

' 5. Final Cleanup and Formatting
ReportSheet.Columns("A:D").AutoFit ' Autofit columns

' 6. Confirmation message
MsgBox "Keyword search complete. Total matches found: " & (nextRow - 2), vbInformation

End Sub
