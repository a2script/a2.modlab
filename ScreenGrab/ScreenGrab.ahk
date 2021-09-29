; Experimental Screen shot tool. The idea is to be less basic than the Windows built-in
; But also much more convenient than tools like ShareX for example.


screengrab() {
    a2tip("ScreenGrab: Draw a rectangle!")
    work_area := screen_get_work_area()
    dimmer_id := dimmer_create(work_area)

    if (ScreenGrab_ShowLastRect) {
        last := a2.db.find(A_LineFile, "last_rectangle")
        if (last) {
            parts := StrSplit(last, ",")
            rect := {x: parts[1], y: parts[2], x2: parts[3], y2: parts[4]}
            window_cut_hole(dimmer_id, rect, work_area)
        }
    }

    data := {area: work_area, dimmer: dimmer_id}
    data := dragtangle("screengrab_dragging", "_screengrab_make_gui",,,, data)
    screengrab_off(data)
}

screengrab_dragging(byref data) {
    txt := "top-left: " . data.x . "," . data.y . "`nsize: " . data.w . "," . data.h "`nbottom-right: " . data.x2 . "," . data.y2
    a2tip("ScreenGrab dragging:`n" . txt)

    ; gui_nam := data.gui
    ; rect := "x" . data.x . " y" . data.y . " w" . data.w . " h" . data.h
    ; Gui %gui_nam%: Show, %rect% NA
    window_cut_hole(data.dimmer, data, data.area)
}

screengrab_off(byref data := "") {
    if (data.done) {
        txt := "top-left: " . data.x . "," . data.y . "`nsize: " . data.w . "," . data.h
        a2tip("ScreenGrab_Off:`n" . txt)
    } else
        a2tip("ScreenGrab_Off")
    rect_str := string_join([data.x, data.y, data.x2, data.y2], ",")
    a2.db.find_set(A_LineFile, "last_rectangle", rect_str)

    window_cut_hole(data.dimmer, data, data.area)
    dimmer_off()
}

_screengrab_make_gui(byref data) {
    gui_name := "screengrab_highlight"
    data.gui := gui_name
    Gui %gui_name%: Destroy
    Gui %gui_name%: +AlwaysOnTop +Caption -Border +ToolWindow +LastFound -DPIScale
    WinSet, Transparent, 55
    Gui %gui_name%: Color, White
}
