; WebSearch - WebSearch.ahk
; author: eric
; created: 2021 8 19

WebSearch() {
    if (!WebSearch_data) {
        a2dlg_info("Nothing set up?!, Please open the user interface of `"WebSearch`" and add at least one item.")
        Return
    }

    global _web_search_selection := clipboard_get()

    WebSearchMenu := Menu()
    for name, data in WebSearch_data
        WebSearchMenu.Add(name, WebSearch_handler)

    WebSearchMenu.Show()
}

WebSearch_handler(menu_name, *) {
    global _web_search_selection
    if (IsSet(_web_search_selection) AND _web_search_selection) {
        phrase := _web_search_selection
        _web_search_selection := ""
    } else
        phrase := clipboard_get()

    if (!phrase) {
        msg := "Nothing selected! What do you want to look up on " menu_name "?"
        result := string_strip(a2dlg_input(msg, 'WebSearch - ' menu_name ))
        if !result
            Return
    }

    url := StrReplace(WebSearch_data[menu_name]["url"], "###", phrase)
    a2tip("WebSearch: " menu_name " ...")
    Run(url)
}
