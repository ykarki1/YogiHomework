Attribute VB_Name = "Module1"
Moderate
Sub yearly_change()

Dim openingval As Long, closingval As Double, percentchange As Double, yearlychange As Double, total As Double
openingval = 2
yearlychange = 0

Dim i As Integer, j As Integer
Range("I1").Value = "Ticker"
Range("J1").Value = "Yearly change"
Range("K1").Value = "Percent change"
Range("L1").Value = "Total Stock Volume"

lastrow = Cells(Rows.Count, 1).End(xlUp).Row

total = 0
j = 2

For i = 2 To 900
        
If Cells(i + 1, 1).Value <> Cells(i, 1) Then
    total = Cells(i, 7) + total
    If total = 0 Then
        Range("I" & j).Value = Cells(i, 1).Value
        Range("J" & j).Value = 0
        Range("K" & j).Value = 0
        Range("L" & j).Value = 0
    Else
        If Cells(openingval, 3).Value = 0 Then

    For finder = openingval To i
        If Cells(finder, 3).Value <> 0 Then
        openingval = finder
        Exit For
        End If
    Next finder
    End If
yearlychange = Cells(i, 6).Value - Cells(openingval, 3).Value
percentchange = Round((yearlychange / Cells(openingval, 3)) * 100, 2)
openingval = i + 1


Range("I" & j).Value = Cells(i, 1).Value
Range("J" & j).Value = yearlychange
Range("K" & j).Value = "%" & percentchange
Range("L" & j).Value = total
j = j + 1
total = 0
Else
total = total + Cells(i, 7)
End If

Next i

End Sub

