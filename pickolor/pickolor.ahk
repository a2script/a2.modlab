; Pickolor color picker script

pickolor() {
    global _pickolor
    static _pickolor_guid, _pickolor_label, _pickolor_text
    max_draw_every := 3
    _pickolor_count := 100

    CoordMode "Mouse", "Screen"
    MouseGetPos &mx, &my
    CoordMode "Pixel", "Screen"
    _pickolor := PixelGetColor(mx, my, "RGB")

    pickolor_gui := Gui("+LastFound +AlwaysOnTop -Caption +ToolWindow +Border")
    pickolor_gui.BackColor := _pickolor
    pickolor_gui.SetFont("s21 Bold", "Consolas")
    pickolor_text := pickolor_gui.Add("Text",, "#AABBCC")
    pickolor_gui.Show("x" mx " y" my " NoActivate")

    CoordMode "Mouse", "Screen"

    Loop {
        if (GetKeyState("Escape")) {
            pickolor_gui.Destroy()
            a2tip("pickolor: Escaped")
            cursor_reset()
            Return
        }

        MouseGetPos &mx, &my
        mon_nfo := MDMF_GetInfo(MDMF_FromPoint(&mx, &my))
        ; a2tip("mouse: " mx " " my "`nmon nr: " mon_nfo.Num " " mon_nfo.name "`nltrb: " mon_nfo.left " " mon_nfo.top " " mon_nfo.right " " mon_nfo.bottom "WA:" mon_nfo.WAleft " " mon_nfo.WAtop " " mon_nfo.WAright " " mon_nfo.WAbottom)
        if (mx > (mon_nfo.right - 300))
            wx := mx - 230
        else
            wx := mx + 20

        if (my > (mon_nfo.bottom - 200))
            wy := my - 100
        else
            wy := my + 20
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

        cursor_set_cross()

        hex_list := _pickolor_split_hex(_pickolor)
        rgb_list := _pickolor_split_rgb(hex_list)
        brightness := (rgb_list[1] + rgb_list[2] + rgb_list[3]) / 3

        if (brightness > 100.0)
            pickolor_text.SetFont("cBlack")
        else
            pickolor_text.SetFont("cWhite")

        pickolor_text.Text := "#" hex_list[1] hex_list[2] hex_list[3]
        pickolor_gui.BackColor := _pickolor
        Sleep 50
    }
}


_pickolor_picked(color) {
    hex_list := _pickolor_split_hex(color)
    rgb_list := _pickolor_split_rgb(hex_list)
    float_list := _pickolor_split_float(rgb_list)
    hex_label := "hex #" hex_list[1] hex_list[2] hex_list[3]
    rgb_label := "rgb " rgb_list[1] "," rgb_list[2] "," rgb_list[3]
    float_label := "float " float_list[1] "," float_list[2] "," float_list[3]

    pickolor_menu := Menu()
    pickolor_menu.Add(hex_label, _pickolor_Hex)
    pickolor_menu.Add(rgb_label, _pickolor_255)
    pickolor_menu.Add(float_label, _pickolor_Float)
    pickolor_menu.Show()
}

_pickolor_split_hex(color) {
    hex_list := [SubStr(color, 3, 2), SubStr(color, 5, 2), SubStr(color, 7, 2)]
    Return hex_list
}

_pickolor_split_rgb(hex_list) {
    rgb_list := [_pickolor_hex_to_int(hex_list[1])
    , _pickolor_hex_to_int(hex_list[2])
    , _pickolor_hex_to_int(hex_list[3])]
    Return rgb_list
}

_pickolor_hex_to_int(Hex) {
    Int := "0x" . Hex
    Int += 0
    Return Int
}

_pickolor_split_float(rgb_list) {
    float_list := [Format("{1:0.3f}", rgb_list[1] / 255)
    ,Format("{1:0.3f}", rgb_list[2] / 255)
    ,Format("{1:0.3f}", rgb_list[3] / 255)]
    Return float_list
}


_pickolor_Hex(*) {
    global _pickolor
    hex_list := _pickolor_split_hex(_pickolor)
    hex_label := "#" hex_list[1] hex_list[2] hex_list[3]
    a2tip("PiCked: HEX " hex_label)
    A_Clipboard := hex_label
}

_pickolor_255(*) {
    global _pickolor
    rgb_list := _pickolor_split_rgb(_pickolor_split_hex(_pickolor))
    rgb_label := rgb_list[1] "," rgb_list[2] "," rgb_list[3]
    a2tip("PiCked: rgb 255 " rgb_label)
    A_Clipboard := rgb_label
}

_pickolor_Float(*) {
    global _pickolor
    float_list := _pickolor_split_float(_pickolor_split_rgb(_pickolor_split_hex(_pickolor)))
    float_label := float_list[1] "," float_list[2] "," float_list[3]
    a2tip("PiCked: rgb 0.0-1.0 " float_label)
    A_Clipboard := float_label
}
