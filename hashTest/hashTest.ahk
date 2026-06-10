; hashTest - hashTest.ahk
; author: eric
; created: 2022 6 9
#include <a2dlg>
#include <python>

hashTest() {
    selection := explorer_get_selected()
    if (selection.Length != 1) {
        a2dlg_error("Select 1 File!", "hashTest")
        return
    }

    ; get hash value from python hash getter script:
    output := string_strip(StrUpper(python_get_output(path_neighbor(A_LineFile, "hashtest.py"), selection[1])))
    ; check against clipboard
    clip_val := string_strip(StrUpper(A_Clipboard))
    if (StrLen(output) != StrLen(clip_val)) {
        A_Clipboard := output
        msg := 'From the selected file "' path_basename(selection[1]) '"`n'
        msg .= "I got this sha256 hash and put it to the clipboard:`n`n  " output
        a2dlg_info(msg, "hashTest - got hash")
        Return
    }
    if (output == clip_val) {
        msg := 'Hash values Match! From the selected file "' path_basename(selection[1]) '" '
        msg .= 'I got this hash and it matches with the one in the clipboard:`n' output
        a2dlg_info(msg, "hashTest - It's A Match!")
    }
    else {
        msg := "The clipboard contains a string of matching length!`n"
        msg .= 'But it does NOT match the hash I got from the selected file "' path_basename(selection[1]) '"`n'
        msg .= output " != " clip_val
        a2dlg_error(msg, "hashTest - Mismatch!")
    }
}
