; TaskbarRaiser - taskbar_raiser.ahk
; author: eric
; created: 2020 7 30
#Include <screen>
#Include <window>

taskbar_raiser_init() {
    SetTimer taskbar_raiser_check, TaskbarRaiser_Interval
}


taskbar_raiser_check() {
    static workarea := ""
    static active_index := 0
    id := WinExist("A")

    new_index := screen_get_index(id)
    if active_index != new_index OR workarea == "" {
        workarea := Screen_Workarea(active_index)
        active_index := new_index
    }
    tb_signature := "ahk_class Shell_TrayWnd ahk_exe explorer.exe"
    tb_id := WinExist(tb_signature)

    CoordMode "Mouse", "Screen"
	MouseGetPos , &mousey, &id_under_cursor
    dist := workarea.bottom - mousey
    if (dist > TaskbarRaiser_Distance) {
        ; a2tip("TaskbarRaiser: Cursor not at Taskbar!")
        Return
    }

    if tb_id == id_under_cursor {
        ; a2tip("TaskbarRaiser: under cursor is Taskbar!")
        return
    }

    if (id == 0 OR id == tb_id) {
        ; a2tip("TaskbarRaiser: Active is Taskbar!")
        return
    }

    if !window_is_fullscreen(id, workarea) {
        ; a2tip("TaskbarRaiser: Active is not fullscreen!")
        return
    }

    if TaskbarRaiser_CheckRDC {
        this_class := WinGetClass("ahk_id " . id_under_cursor)
	    this_process := WinGetProcessName("ahk_id " . id_under_cursor)
        if (this_class == "TscShellContainerClass" AND this_process == "mstsc.exe") {
            Return
        }
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
