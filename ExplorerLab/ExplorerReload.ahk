#Include <a2dlg>
#Include <processes>


ExplorerHotkeys_ReloadAll() {
    a2tip("Getting Explorers ...")
    explorers := window_list(,,"CabinetWClass")
    pids := processes_list_ids("explorer.exe")
    paths := []
    if (explorers.Length) {
        txt := "Found " explorers.Length " Explorer windows "
        for i, win in explorers
        {
            path := explorer_get_path(win.id)
            if (string_is_in_array(path, paths))
                Continue
            paths.Push(path)
        }
        if (paths.Length == 1)
            txt .= "with 1 path:`n " paths[1]
        else
            txt .= "with " paths.Length " different paths:`n " string_join(paths, "`n ")
    } else
        txt := "Found no Explorer windows but " pids.Length " processes."

    a2tip()
    txt .= "`n`nDo you want to shut down and reload now?"
    if !a2dlg_ok_cancel(txt, "ExplorerHotkeys ReloadAll")
        return

    for i, pid in pids
    {
        a2tip("Closing PID: " pid)
        ProcessClose(pid)
    }

    Sleep 100
    if !(paths)
        explorer_show("")
    else {
        for i, path in paths
            explorer_show(path)
    }

    pids := processes_list_ids("explorer.exe")
    a2tip(pids.Length " procs after: " string_join(pids))
}