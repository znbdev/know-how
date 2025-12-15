''''''''''''''''''''''''''''''''''''''''''''''''''
' ExtractAllShapeText
''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit

Sub ExtractAllShapeText()
'---------------------------------------------------------------
' Function: Extract text content from all shapes in Excel files
'           in the same folder
'           Results include file name, sheet name, shape name and shape text content
'---------------------------------------------------------------

' Variable Declarations
Dim ReportSheet As Worksheet
Dim folderPath As String
Dim fileName As String
Dim wb As Workbook
Dim ws As Worksheet
Dim nextRow As Long
Dim shp As Shape
Dim shapeText As String
Dim fileCount As Long
Dim totalShapes As Long

' 1. Set the report worksheet (the worksheet running the macro)
Set ReportSheet = ActiveSheet

' 2. Get the folder path
folderPath = ThisWorkbook.Path
If Right(folderPath, 1) <> "\" Then
    folderPath = folderPath & "\"
End If

' 3. Clear previous results and set headers
ReportSheet.Cells.Clear
ReportSheet.Activate
' Apply Meiryo UI font to the entire sheet
ReportSheet.Cells.Font.Name = "Meiryo UI"

ReportSheet.Range("A1:D1").Value = Array("File Name", "Sheet Name", "Shape Name", "Shape Text")
ReportSheet.Range("A1:D1").Font.Bold = True
nextRow = 2 ' Start recording results from row 2
fileCount = 0
totalShapes = 0

Application.ScreenUpdating = False
Application.DisplayAlerts = False

' 4. Start the main file loop
fileName = Dir(folderPath & "*.xls*")

Do While fileName <> ""
    ' Skip the current workbook (the workbook running the macro)
    If fileName <> ThisWorkbook.Name Then
        fileCount = fileCount + 1

        ' Open the workbook silently
        On Error Resume Next
        Set wb = Workbooks.Open(folderPath & fileName, ReadOnly:=True, UpdateLinks:=0)

        If Not wb Is Nothing Then
            ' Search all worksheets in this workbook
            For Each ws In wb.Worksheets
                ' --- Extract text content from all shapes ---
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

                    ' Record shape information
                    ReportSheet.Cells(nextRow, "A").Value = fileName
                    ReportSheet.Cells(nextRow, "B").Value = ws.Name
                    ReportSheet.Cells(nextRow, "C").Value = shp.Name

                    ' Record shape content (replace line breaks with "|")
                    ReportSheet.Cells(nextRow, "D").Value = Replace(shapeText, Chr(10), " | ")
                    nextRow = nextRow + 1
                    totalShapes = totalShapes + 1

NextShape:
                Next shp ' End of shape loop
            Next ws ' End of worksheet loop

            ' Close the workbook without saving
            wb.Close SaveChanges:=False
            Set wb = Nothing
        Else
            ' If unable to open file, record it (optional)
            ReportSheet.Cells(nextRow, "A").Value = fileName
            ReportSheet.Cells(nextRow, "B").Value = "Error"
            ReportSheet.Cells(nextRow, "C").Value = "File"
            ReportSheet.Cells(nextRow, "D").Value = "Unable to open file"
            nextRow = nextRow + 1
        End If

        On Error GoTo 0 ' Resume normal error handling
    End If

    ' Get the next file
    fileName = Dir()
Loop

' 5. Final cleanup and formatting
Application.ScreenUpdating = True
Application.DisplayAlerts = True

ReportSheet.Columns("A:D").AutoFit ' Auto-adjust column width
ReportSheet.Range("A1").Select

' 6. Confirmation message
MsgBox "Shape text extraction complete." & vbCrLf & _
       "Number of files searched: " & fileCount & vbCrLf & _
       "Total shapes extracted: " & totalShapes, vbInformation

End Sub

