; ScreenGrab - ScreenGrab.ahk
; author: eric
; created: 2020 12 24

screengrab() {
    tt("ScreenGrab: Draw a rectangle!", 2)
    work_area := screen_get_work_area()
    dimmer := dimmer_create(work_area)

    data := {area: work_area, dimmer: dimmer}
    data := dragtangle("screengrab_dragging", "_screengrab_make_gui",,,, data)
    screengrab_off(data)
}

screengrab_dragging(byref data) {
    txt := "top-left: " . data.x . "," . data.y . "`nsize: " . data.w . "," . data.h "`nbottom-right: " . data.x2 . "," . data.y2
    tt("ScreenGrab dragging:`n" . txt, 2)

    ; gui_nam := data.gui
    ; rect := "x" . data.x . " y" . data.y . " w" . data.w . " h" . data.h
    ; Gui %gui_nam%: Show, %rect% NA
    window_cut_hole(data.dimmer, data, data.area)
}

screengrab_off(byref data := "") {
    if (sgrab) {
        txt := "top-left: " . sgrab.x . "," . sgrab.y . "`nsize: " . sgrab.w . "," . sgrab.h
        tt("ScreenGrab_Off:`n" . txt, 2)
    } else
    tt("ScreenGrab_Off:", 1)

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
