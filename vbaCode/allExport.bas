Option Explicit
'ver.2026-05-07 cursorがVBA書き換えるようになったので、Cursorに改行コードを揃えた

Private Const EXPORT_TEXT_CHARSET As String = "utf-8"
Private Const EXPORT_LINE_ENDING As String = vbLf

' VBAモジュールをエクスポートして Git 向けに UTF-8(BOM)・LF に正規化する
' .frm は Export のみ（変換しない） ※.frxが絡むため
Private Sub ExportAllModulesUtf8_NoFrmConvert()

    Dim exportPath As String
    exportPath = ThisWorkbook.path & "\vbaCode\"

    Dim fso As Object
    Set fso = CreateObject("Scripting.FileSystemObject")

    If Not fso.FolderExists(exportPath) Then
        fso.CreateFolder exportPath
    End If

    Dim vbProj As Object
    Set vbProj = ThisWorkbook.VBProject

    Dim vbComp As Object
    Dim outPath As String
    Dim ext As String

    For Each vbComp In vbProj.VBComponents

        If Not HasEffectiveCode(vbComp) Then GoTo ContinueLoop

        outPath = ""
        ext = ""

        Select Case vbComp.Type
            Case 1 ' vbext_ct_StdModule
                ext = ".bas"
            Case 2 ' vbext_ct_ClassModule
                ext = ".cls"
            Case 3 ' vbext_ct_MSForm
                ext = ".frm"  ' 変換しない
            Case 100 ' vbext_ct_Document（Sheet/ThisWorkbook）
                ext = ".cls"
            Case Else
                GoTo ContinueLoop
        End Select

        outPath = exportPath & vbComp.Name & ext

        On Error GoTo ExportErr
        vbComp.Export outPath

        ' .bas / .cls だけ UTF-8(BOM)・LF に正規化（.frm は変換しない）
        If ext = ".bas" Or ext = ".cls" Then
            NormalizeTextFileToUtf8Bom outPath, "Shift_JIS"
        End If

ContinueLoop:
        On Error GoTo 0
    Next vbComp

    MsgBox "全モジュールのエクスポートが完了しました。(bas/clsはUTF-8・LF化)" & vbCrLf & exportPath, vbInformation
    Exit Sub

ExportErr:
    MsgBox "Export失敗: " & vbComp.Name & vbCrLf & Err.Description, vbExclamation

End Sub

Private Sub NormalizeTextFileToUtf8Bom(ByVal filePath As String, ByVal srcCharset As String)
    ' ADODB.Stream を使って、指定文字コードで読み、UTF-8(BOM)・LFで上書き保存

    Dim stm As Object
    Set stm = CreateObject("ADODB.Stream")

    stm.Type = 2 ' adTypeText
    stm.Charset = srcCharset
    stm.Open
    stm.LoadFromFile filePath

    Dim text As String
    text = stm.ReadText(-1)
    stm.Close

    text = NormalizeLineEndings(text, EXPORT_LINE_ENDING)

    stm.Type = 2 ' adTypeText
    stm.Charset = EXPORT_TEXT_CHARSET
    stm.Open
    stm.WriteText text, 0 ' adWriteChar
    stm.SaveToFile filePath, 2 ' adSaveCreateOverWrite
    stm.Close

End Sub

Private Function NormalizeLineEndings(ByVal text As String, ByVal lineEnding As String) As String

    text = Replace(text, vbCrLf, vbLf)
    text = Replace(text, vbCr, vbLf)

    If lineEnding <> vbLf Then
        text = Replace(text, vbLf, lineEnding)
    End If

    NormalizeLineEndings = text

End Function

Private Function HasEffectiveCode(vbComp As Object) As Boolean

    Dim cm As Object
    Set cm = vbComp.CodeModule

    If cm.CountOfLines = 0 Then Exit Function

    Dim iRow As Long
    Dim lineText As String

    For iRow = 1 To cm.CountOfLines

        lineText = Trim$(cm.lines(iRow, 1))

        If lineText = "" Then GoTo ContinueLine
        If Left$(lineText, 1) = "'" Then GoTo ContinueLine
        If LCase$(lineText) = "option explicit" Then GoTo ContinueLine

        HasEffectiveCode = True
        Exit Function

ContinueLine:
    Next iRow

End Function
