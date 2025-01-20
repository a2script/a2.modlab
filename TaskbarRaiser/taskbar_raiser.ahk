; TaskbarRaiser - taskbar_raiser.ahk
; author: eric
; created: 2020 7 30

taskbar_raiser_init() {
    SetTimer taskbar_raiser_check, TaskbarRaiser_Interval
}


taskbar_raiser_check() {
    id := WinExist("A")
    tb_signature := "ahk_class Shell_TrayWnd ahk_exe explorer.exe"
    if id == 0 OR id == WinExist(tb_signature)
        return

    ; TODO: We need something like `is_fullscreen` because that's the actual
    ; problem. Just maximized windows still allow the taskbar to come up.
    ; minmax := WinGetMinMax("ahk_id " . id)
    ; a2tip("id:" . id . " minmax:" . minmax)
    ; if minmax != 1
    ;     return

    static workarea := ""
    if (!workarea)
        workarea := screen_Workarea()
    CoordMode "Mouse", "Screen"
	MouseGetPos , &mousey, &id_under_cursor
    dist := workarea.bottom - mousey
    if (dist > TaskbarRaiser_Distance) {
        Return
    }

    if TaskbarRaiser_CheckRDC {
        this_class := WinGetClass("ahk_id " . id_under_cursor)
	    this_process := WinGetProcessName("ahk_id " . id_under_cursor)
        if (this_class == "TscShellContainerClass" AND this_process == "mstsc.exe")
            Return
    }

    Loop 10 {
        try {
            WinActivate(tb_signature)
            if TaskbarRaiser_CheckTip {
                a2tip("TaskbarRaised!")
            }
            return
        }
        catch TargetError {
            Sleep(100)
        }
    }

    a2tip('Could NOT raise taskbar after 10 tries :/`nsignature: " . tb_signature . "')
}
