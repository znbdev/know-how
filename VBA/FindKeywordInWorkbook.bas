''''''''''''''''''''''''''''''''''''''''''''''''''
' FindKeywordInWorkbook
''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit
Sub FindKeywordInWorkbook()
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
    Title:="Keyword Search", _
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
