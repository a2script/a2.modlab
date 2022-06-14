; ExplorerDiff - ExplorerDiff.ahk
; author: teric
; created: 2022 2 2

ExplorerDiff() {
    files := explorer_get_selected()

    if (!files.Length()) {
        a2tip("ExplorerDiff: Nothing selected!")
        return
    } else if (files.Length() != 2) {
        MsgBox, Please select 2 files exactly!
    }

    if !FileExist(ExplorerDiff_Path) {
        if (ExplorerDiff_Path == "")
            MsgBox, No Diff app set! Please open the dialog and set one!
        else
            MsgBox, Unable to find set diff app! The path seems to be invalid!`n`n %ExplorerDiff_Path%`n??
        Return
    }

    file1 := files[1], file2 := files[2]
    size1 := FileGetSize(file1), size2 := FileGetSize(file2)

    if (size1 == size2) {
        identical := true
        Loop
        {
            FileReadLine, line1, %file1%, %A_Index%
            FileReadLine, line2, %file2%, %A_Index%
            if ErrorLevel
                break
            if (line1 != line2) {
                identical := false
                Break
            }
        }
        if (identical) {
            a2tip("ExplorerDiff: Files are identical!")
            Return
        }
    } else
        a2tip("ExplorerDiff: Sizes different ... (" size1 "/" size2 ")")

    cmd := """" ExplorerDiff_Path """ """ files[1] """ """ files[2] """"
    Run(cmd)
}
