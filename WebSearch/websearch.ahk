; WebSearch - websearch.ahk
; author: eric
; created: 2021 8 19

websearch() {
    if !websearch_data
    {
        MsgBox("Nothing set up?!, Please open the user interface of `"WebSearch`" and add at least one item.")
        Return
    }

    global _webseach_selection := clipboard_get()

    WebSearchMenu := Menu()
    for name, data in websearch_data
        WebSearchMenu.Add(name, websearch_handler)

    WebSearchMenu.Show()
}

websearch_handler(menu_name, *) {
    global _webseach_selection
    if _webseach_selection
    {
        phrase := _webseach_selection
        _webseach_selection := ""
    } else
        phrase := clipboard_get()

    if (!phrase) {
        msg := "Nothing selected! What do you want to look up on " menu_name "?"
        ibx := InputBox(msg, 'WebSearch "' menu_name '"', "w450 h130")
        if ibx.Result = "Cancel"
            Return
        if !phrase
            Return
    }

    url := StrReplace(websearch_data[menu_name]["url"], "###", phrase)
    a2tip("WebSearch: " menu_name " ...")
    Run url
}
