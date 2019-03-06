Attribute VB_Name = "Module1"
Sub stock_easy()

For Each ws In ActiveWorkbook.Worksheets

    RowCount = ws.Cells(Rows.Count, "A").End(xlUp).Row
    ws.Range("I1").Value = "Ticker"
    ws.Range("J1").Value = "Total Volume"
    Dim ticker As String
    Dim totalvol As Variant
    totalvol = 0
    Dim j As Integer
    j = 2
        For i = 2 To RowCount
            If ws.Cells(i + 1, 1).Value <> ws.Cells(i, 1).Value Then
            ticker = ws.Cells(i, 1).Value
            totalvol = ws.Cells(i, 7) + totalvol
            ws.Range("I" & j).Value = ticker
            ws.Range("J" & j).Value = totalvol
            j = j + 1
            totalvol = 0
        Else
            totalvol = totalvol + ws.Cells(i, 7).Value
        End If
    Next i
    
Next

End Sub

