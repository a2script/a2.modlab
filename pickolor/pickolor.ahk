; Pickolor color picker script
#Include <string>

pickolor() {
    global _pickolor, _pickolor_l_click, _pickolor_escape

    ; to ease the amount of redraws let's not draw every loop:
    max_draw_every := 3
    _pickolor_count := 3
    ; wait a moment in each loop
    loop_slag := 40

    _pickolor_l_click := false
    _pickolor_escape := false

    CoordMode("Mouse", "Screen")
    MouseGetPos(&mx, &my)
    CoordMode("Pixel", "Screen")
    _pickolor := PixelGetColor(mx, my, "RGB")

    pickolor_gui := Gui("+LastFound +AlwaysOnTop -Caption +ToolWindow +Border")
    pickolor_gui.BackColor := _pickolor
    pickolor_gui.SetFont("s21 Bold", "Consolas")
    pickolor_text := pickolor_gui.Add("Text",, "#AABBCC")
    pickolor_gui.Show("x" mx " y" my " NoActivate")

    mon_nfo := MDMF_GetInfo(MDMF_FromPoint(&mx, &my))

    Hotkey("Escape", _on_pickolor_escape := (*) => (_pickolor_escape := true), "On")
    Hotkey("LButton", _on_pickolor_l_click := (*) => (_pickolor_l_click := true), "On")

    CoordMode("Mouse", "Screen")

    Loop {
        Sleep(loop_slag)

        if (_pickolor_escape OR _pickolor_l_click) {
            _pickolor_cleanup(pickolor_gui, _on_pickolor_escape, _on_pickolor_l_click)
            if (_pickolor_l_click)
                _pickolor_picked(_pickolor)
            Return
        }

        MouseGetPos(&mx, &my)
        gui_w := 230, gui_h := 100, offset := 20
        wx := (mx > mon_nfo.right  - gui_w - offset) ? mx - gui_w : mx + offset
        wy := (my > mon_nfo.bottom - gui_h - offset) ? my - gui_h : my + offset
        WinMove(wx, wy,,, "ahk_id " pickolor_gui.hwnd)

        _pickolor_count += 1
        if (_pickolor_count < max_draw_every)
            continue

        _pickolor_count := 0
        _pickolor := PixelGetColor(mx, my, "RGB")

        if GetKeyState("LButton") {
            pickolor_gui.Destroy()
            cursor_reset()
            _pickolor_picked(_pickolor)
            Return
        }

        ; Keep cross cursor as long we're active. Prevent other apps from change.
        cursor_set_cross()

        hex_list := _pickolor_split_hex(_pickolor)
        rgb_list := _pickolor_split_rgb(hex_list)
        brightness := 0.299 * rgb_list[1] + 0.587 * rgb_list[2] + 0.114 * rgb_list[3]
        if (brightness > 100.0)
            pickolor_text.SetFont("cBlack")
        else
            pickolor_text.SetFont("cWhite")

        pickolor_text.Text := "#" hex_list[1] hex_list[2] hex_list[3]
        pickolor_gui.BackColor := _pickolor
    }
}

_pickolor_cleanup(pickolor_gui, fn_esc, fn_click) {
    Hotkey("Escape", fn_esc, "Off")
    Hotkey("LButton", fn_click, "Off")
    _pickolor_l_click := false
    _pickolor_escape := false
    pickolor_gui.Destroy()
    cursor_reset()
}

_pickolor_picked(color) {
    hex_list := _pickolor_split_hex(color)
    rgb_list := _pickolor_split_rgb(hex_list)
    float_list := _pickolor_split_float(rgb_list)
    hex_label := "hex #" hex_list[1] hex_list[2] hex_list[3]
    rgb_label := "rgb " rgb_list[1] "," rgb_list[2] "," rgb_list[3]
    palette_label := "palette " rgb_list[1] " " rgb_list[2] " " rgb_list[3]
    float_label := "float " float_list[1] "," float_list[2] "," float_list[3]

    pickolor_menu := Menu()
    pickolor_menu.Add(hex_label, _pickolor_Hex)
    pickolor_menu.Add(rgb_label, (*) => _pickolor_255(","))
    pickolor_menu.Add(palette_label, (*) => _pickolor_255(" "))
    pickolor_menu.Add(float_label, _pickolor_Float)
    pickolor_menu.Show()
}

_pickolor_split_hex(color) {
    Return [
        SubStr(color, 3, 2),
        SubStr(color, 5, 2),
        SubStr(color, 7, 2)
    ]
}

_pickolor_split_rgb(hex_list) {
    Return [
        Integer("0x" hex_list[1]),
        Integer("0x" hex_list[2]),
        Integer("0x" hex_list[3])
    ]
}

_pickolor_split_float(rgb_list) {
    Return [
        Format("{1:0.3f}", rgb_list[1] / 255),
        Format("{1:0.3f}", rgb_list[2] / 255),
        Format("{1:0.3f}", rgb_list[3] / 255)
    ]
}

_pickolor_Hex(*) {
    hex_list := _pickolor_split_hex(_pickolor)
    hex_label := "#" hex_list[1] hex_list[2] hex_list[3]
    a2tip("PiCked HEX: " hex_label)
    A_Clipboard := hex_label
}

_pickolor_255(sep, *) {
    rgb_list := _pickolor_split_rgb(_pickolor_split_hex(_pickolor))
    label := string_join(rgb_list, sep)
    a2tip("PiCked 255-style: " label)
    A_Clipboard := label
}

_pickolor_Float(*) {
    float_list := _pickolor_split_float(_pickolor_split_rgb(_pickolor_split_hex(_pickolor)))
    float_label := float_list[1] "," float_list[2] "," float_list[3]
    a2tip("PiCked float: 0.0-1.0 " float_label)
    A_Clipboard := float_label
}
