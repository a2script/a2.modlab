; Pickolor color picker script

pickolor() {
    global _pickolor
    static _pickolor_guid, _pickolor_label, _pickolor_text
    max_draw_every := 3
    _pickolor_count := 100

    batch_lines_b4 := A_BatchLines
    SetBatchLines, 2000
    CoordMode, Mouse, Screen
    MouseGetPos, mx, my
    CoordMode, Pixel, Screen
    PixelGetColor, _pickolor, %mx%, %my%, RGB

    Gui, New, +Hwnd_pickolor_guid +LastFound +AlwaysOnTop -Caption +ToolWindow +Border
    Gui, Color, %_pickolor%
    Gui, Font, s21 Bold, Consolas
    Gui, Add, Text, +Hwnd_pickolor_label, #AABBCC
    Gui, Show, x%mx% y%my% NoActivate

    ; cursor_set_cross()
    ; SetTimer, _pickolor_callback, 10
    CoordMode, Mouse, Screen

    Loop
    {
    ; _pickolor_callback:
        GetKeyState, pcl_escape, Escape, P
        if (pcl_escape == "D") {
            ; SetTimer, _pickolor_callback, Off
            SetBatchLines, %batch_lines_b4%
            Gui %_pickolor_guid%:Destroy
            a2tip("pickolor: Escaped")
            cursor_reset()
            Return
        }

        MouseGetPos, mx, my
        mon_nfo := MDMF_GetInfo(MDMF_FromPoint(mx, my))
        ; a2tip("mouse: " mx " " my "`nmon nr: " mon_nfo.Num " " mon_nfo.name "`nltrb: " mon_nfo.left " " mon_nfo.top " " mon_nfo.right " " mon_nfo.bottom "WA:" mon_nfo.WAleft " " mon_nfo.WAtop " " mon_nfo.WAright " " mon_nfo.WAbottom)
        if (mx > (mon_nfo.right - 300))
            wx := mx - 230
        else
            wx := mx + 20

        if (my > (mon_nfo.bottom - 200))
            wy := my - 100
        else
            wy := my + 20
        WinMove, ahk_id %_pickolor_guid%,, %wx%, %wy%

        _pickolor_count += 1
        if (_pickolor_count < max_draw_every)
            continue

        _pickolor_count := 0
        PixelGetColor, _pickolor, %mx%, %my%, RGB

        GetKeyState, pcl_lbutton, LButton, P
        if (pcl_lbutton == "D") {
            ; SetTimer, _pickolor_callback, Off
            SetBatchLines, %batch_lines_b4%
            Gui %_pickolor_guid%:Destroy
            cursor_reset()
            _pickolor_picked(_pickolor)
            Return
        }

        cursor_set_cross()

        hex_list := _pickolor_split_hex(_pickolor)
        rgb_list := _pickolor_split_rgb(hex_list)
        brightness := (rgb_list[1] + rgb_list[2] + rgb_list[3]) / 3

        if (brightness > 100.0)
            GuiControl, +cBlack, %_pickolor_label%
        else
            GuiControl, +cWhite, %_pickolor_label%

        txt := "#" hex_list[1] hex_list[2] hex_list[3]
        GuiControl,, %_pickolor_label%, %txt%
        Gui, %_pickolor_guid%:Color, %_pickolor%
    }
}


_pickolor_picked(color) {
    hex_list := _pickolor_split_hex(color)
    rgb_list := _pickolor_split_rgb(hex_list)
    float_list := _pickolor_split_float(rgb_list)
    hex_label := "hex #" hex_list[1] hex_list[2] hex_list[3]
    rgb_label := "rgb " rgb_list[1] "," rgb_list[2] "," rgb_list[3]
    float_label := "float " float_list[1] "," float_list[2] "," float_list[3]

    Menu, pickolorMenu, Add, %hex_label%, _pickolor_Hex
    Menu, pickolorMenu, Add, %rgb_label%, _pickolor_255
    Menu, pickolorMenu, Add, %float_label%, _pickolor_Float
    Menu, pickolorMenu, Show
    Menu, pickolorMenu, DeleteAll
}

_pickolor_split_hex(color) {
    hex_list := [SubStr(color, 3, 2), SubStr(color, 5, 2), SubStr(color, 7, 2)]
    Return hex_list
}

_pickolor_split_rgb(byref hex_list) {
    rgb_list := [_pickolor_hex_to_int(hex_list[1])
    , _pickolor_hex_to_int(hex_list[2])
    , _pickolor_hex_to_int(hex_list[3])]
    Return rgb_list
}

_pickolor_hex_to_int(byref Hex) {
    Int := "0x" . Hex
    Int += 0
    Return Int
}

_pickolor_split_float(byref rgb_list) {
    float_list := [Format("{1:0.3f}", rgb_list[1] / 255)
    ,Format("{1:0.3f}", rgb_list[2] / 255)
    ,Format("{1:0.3f}", rgb_list[3] / 255)]
    Return float_list
}


_pickolor_Hex() {
    global _pickolor
    hex_list := _pickolor_split_hex(_pickolor)
    hex_label := "#" hex_list[1] hex_list[2] hex_list[3]
    a2tip("PiCked: HEX " hex_label)
    Clipboard := hex_label
}

_pickolor_255() {
    global _pickolor
    rgb_list := _pickolor_split_rgb(_pickolor_split_hex(_pickolor))
    rgb_label := rgb_list[1] "," rgb_list[2] "," rgb_list[3]
    a2tip("PiCked: rgb 255 " rgb_label)
    Clipboard := rgb_label
}

_pickolor_Float() {
    global _pickolor
    float_list := _pickolor_split_float(_pickolor_split_rgb(_pickolor_split_hex(_pickolor)))
    float_label := float_list[1] "," float_list[2] "," float_list[3]
    a2tip("PiCked: rgb 0.0-1.0 " float_label)
    Clipboard := float_label
}
