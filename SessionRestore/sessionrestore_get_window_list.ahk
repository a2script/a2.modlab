#Requires AutoHotkey v2.0

sessionrestore_get_window_list(hidden:=false, process_name:="") {
    current_detect_state := A_DetectHiddenWindows
    if current_detect_state != hidden
        DetectHiddenWindows(hidden)

    window_list := []

    for this_id in WinGetlist() {
        ahk_id := "ahk_id " this_id
        this_proc := WinGetProcessName(ahk_id)
        if (process_name && this_proc != process_name)
            continue

        this_class := WinGetClass(ahk_id)
        WinGetPos(&x, &y, &w, &h, ahk_id)
        this_title := WinGetTitle(ahk_id)
        this_minmax := WinGetMinMax(ahk_id)

        window_list.push(_sessionrestore_window(this_proc, this_title, this_class, x, y, w, h, this_id, A_Index, this_minmax))
    }

    if current_detect_state != hidden
        DetectHiddenWindows(current_detect_state)

    return window_list
}

class _sessionrestore_window {
    __New(proc_name, win_title, win_class, x, y, w, h, id, index, minmax) {
        this.proc_name := proc_name
        this.title := win_title
        this.class := win_class
        this.x := x
        this.y := y
        this.w := w
        this.h := h
        this.id := id
        this.index := index
        this.minmax := minmax
    }
}
