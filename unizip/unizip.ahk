; unizip - unizip.ahk - An Autohotkey version of Cary HKs Unicrush: https://htwins.net/unicrush
; author: eric
; created: 2021 2 23

unizip() {
    selection := clipboard_get()
    if !selection
        return

    static letters
    if !letters
        letters := unizip_get_letters()

    count := 0
    new_string := selection
    for chars, replacement in letters {
        if InStr(new_string, chars) {
            new_string := StringReplace(new_string, chars, replacement, 1)
            count++
        }
    }

    clipboard_paste(new_string)

    if !count
        tt("UniZip: Nothing replaced", 1)
    else {
        tt("UniZip: Found " count " items.`nCharacters before/now:" StrLen(selection) "/" StrLen(new_string), 3)
    }
}

unizip_get_letters() {
    letters := {}
    FileEncoding, UTF-8
    letters_file := path_join(path_dirname(A_LineFile), "letters.txt")
    Loop, Read, %letters_file%
    {
        line := Trim(A_LoopReadLine)
        if !line
            Continue

        chars := StrSplit(A_LoopReadLine, " ")
        letters[chars[1]] := chars[2]
    }
    Return letters
}