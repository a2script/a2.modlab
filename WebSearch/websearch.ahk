; WebSearch - websearch.ahk
; author: eric
; created: 2021 8 19

websearch() {
    if !websearch_data
    {
        MsgBox, Nothing set up?!, Please open the user interface of "WebSearch" and add at least one item.
        Return
    }

    global _webseach_selection := clipboard_get()

    for name, data in websearch_data
        Menu, WebSearchMenu, Add, %name%, websearch_handler

    Menu, WebSearchMenu, Show
    Menu, WebSearchMenu, DeleteAll
}

websearch_handler(menu_name) {
    global _webseach_selection
    if _webseach_selection
    {
        phrase := _webseach_selection
        _webseach_selection := ""
    } else
        phrase := clipboard_get()

    if (!phrase) {
        msg := "Nothing selected! What do you want to look up on " menu_name "?"
        InputBox, phrase, WebSearch "%menu_name%", %msg%,,450, 130,,,,,
        if ErrorLevel
            Return
        if !phrase
            Return
    }

    url := StringReplace(websearch_data[menu_name]["url"], "###", phrase)
    a2tip("WebSearch: " menu_name " ...")
    Run, %url%
}
