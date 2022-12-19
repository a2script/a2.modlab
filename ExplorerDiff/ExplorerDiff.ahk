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
        Return
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

    time0 := time_unix()
    if (size1 != size2) {
        a2tip("ExplorerDiff: Sizes different ... (" size1 "/" size2 ")")
        ExplorerDiff_Run(files)
        Return
    }

    if (size1 > (ExplorerDiff_MaxSize * 1024 * 1024)) {
        a2tip("ExplorerDiff: Files bigger than " ExplorerDiff_MaxSize " MB ... ")
        ExplorerDiff_Run(files)
        Return
    }

    a2tip("ExplorerDiff: reading file 1 ...", 60)
    FileRead, contents, %file1%
    lines1 :=   []
    Loop, parse, contents, `n
        lines1.Insert(A_LoopField)

    a2tip("ExplorerDiff: reading file 2 ...", 60)
    FileRead, contents, %file2%
    lines2 :=   []
    Loop, parse, contents, `n
        lines2.Insert(A_LoopField)
    contents :=

    if (lines1.Length() != lines2.Length()) {
        a2tip("ExplorerDiff: Different line lenghts ... (" lines1.Length() "/" lines2.Length() ")")
        ExplorerDiff_Run(files)
        Return
    }

    a2tip("ExplorerDiff: Same size, testing line by line ...")
    identical := true
    len := 0
    Loop % lines1.Length()
    {
        len += StrLen(line1)
        if (lines1[A_Index] != lines2[A_Index]) {
            a2tip("ExplorerDiff: Found Difference on line " A_Index " ... ", 15)
            ExplorerDiff_Run(files)
            Return
        }
        if Mod(A_Index, 10000) == 0
        {
            time_passed := time_unix() - time0
            a2tip("ExplorerDiff: Same size, testing line by line " A_Index)
        }
    }

    msgbox_info("ExplorerDiff: Files are identical!")
}


ExplorerDiff_Run(files) {
    cmd := """" ExplorerDiff_Path """ """ files[1] """ """ files[2] """"
    Run(cmd)
}
