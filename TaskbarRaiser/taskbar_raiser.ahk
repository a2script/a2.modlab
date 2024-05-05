; TaskbarRaiser - taskbar_raiser.ahk
; author: eric
; created: 2020 7 30

taskbar_raiser_init() {
    global TaskbarRaiser_Interval
    SetTimer taskbar_raiser_check, TaskbarRaiser_Interval
}


taskbar_raiser_check() {
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

    taskbar_id := WinGetID("ahk_class Shell_TrayWnd ahk_exe Explorer.EXE")
    if (id_under_cursor != taskbar_id)
        WinActivate("ahk_id " . taskbar_id)
}
