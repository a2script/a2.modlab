; uniformat.ahk


uniformat_main() {
    global _uniformat_selection
    _uniformat_selection := clipboard_get()
    if !_uniformat_selection {
        a2tip("UniFormat: Nothing selected!")
        return
    }

    sets := []
    sets_dir := path_neighbor(A_LineFile, "sets")
    sets_pattern := path_join(sets_dir, "*.txt")
    Loop, Files, % sets_pattern
    {
        Menu, UniFormatMenu, Add, %A_LoopFileName%, uniformat_replace
        sets.Push(A_LoopFileName)
    }
    Menu, UniFormatMenu, Add
    Menu, UniFormatMenu, Add, Cancel, uniformat_replace
    Menu, UniFormatMenu, Show
    Menu, UniFormatMenu, DeleteAll
}

uniformat_replace(set_name) {
    ; static all_letters
    global _uniformat_selection
    letters := uniformat_get_letters(set_name)
    if (set_name == "Cancel" and !letters)
        Return

    count := 0
    new_string := _uniformat_selection
    current_case := A_StringCaseSense
    StringCaseSense, On
    for replacement, chars in letters {
        if InStr(new_string, chars) {
            new_string := StrReplace(new_string, chars, replacement)
            count++
        }
    }
    StringCaseSense, %current_case%

    clipboard_paste(new_string)

    if !count
        a2tip("UniZip: Nothing replaced")
    else {
        msg := "UniZip: Found " count " items.`nCharacters before/now:"
        a2tip(msg StrLen(_uniformat_selection) "/" StrLen(new_string), 3)
    }
}


uniformat_get_letters(set_name) {
    ; Get data from a sets txt by spliting by spaces and
    ; getting 1st as key and 2nd as value.
    letters := {}
    passed_comments := 0
    FileEncoding, UTF-8

    letters_file := path_neighbor(A_LineFile, "sets\" string_suffix(set_name, ".txt"))

    Loop, Read, %letters_file%
    {
        line := Trim(A_LoopReadLine)
        if !line
            Continue

        if (!passed_comments and string_startswith(line, "#"))
            Continue
        passed_comments := 1

        chars := StrSplit(A_LoopReadLine, " ")
        letters[chars[2]] := chars[1]
    }

    Return letters
}
