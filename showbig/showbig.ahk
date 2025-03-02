; showbig - showbig.ahk
; author: eric
; created: 2025 3 2
#Include <clipboard>

showbig() {
    selection := Trim(clipboard_get())
    if (!selection) {
        a2tip("Nothing selected! :/")
        Return
    }

    ; MouseGetPos &mx, &my
    ; mon_nfo := MDMF_GetInfo(MDMF_FromPoint(&mx, &my))

    showbigui := Gui("+LastFound +AlwaysOnTop -Caption +ToolWindow -Border")
    showbigui.OnEvent("Escape", showbigui.Destroy)
    ; showbigui.BackColor := _pickolor
    showbigui.SetFont("s21 Bold", "Consolas")
    pickolor_text := showbigui.AddText(, selection)
    showbigui.Show()
}