; PowerControl - PowerControl.ahk
; author: eric
; created: 2022 10 7
; Making lots of use of ac'tivAid_PowerControl by Wolfgang Reszel 2008
; TODO: The shutdown stuff is not yet implemented.


PowerControl_DisplayOff() {
    this_key := ""
    If (PowerControl_DisplayOffTimeout > 0)
        {
        eschook := InputHook("V M I L1", "{Esc}")
        eschook.start()
        esc := Chr(27)

        msg := "Turning off display in " PowerControl_DisplayOffTimeout "..."
        ; SplashImage,,b1 cwFFFFc0 FS9 WS700 w400, %msg%
        a2tip(msg)
        now := A_TickCount
        Loop
        {
            ; Input, this_key, V M T%PowerControl_DisplayOffTimeout% I L1
            this_key := eschook.Input
            If (this_key == esc OR ErrorLevel == "Timeout" )
                break

            If ((A_TickCount - now) / 1000 >= PowerControl_DisplayOffTimeout)
            {
                ErrorLevel := "Timeout"
                break
            }
        }
        a2tip()
        ; SplashImage, Off
    }

    If (this_key != esc OR ErrorLevel == "Timeout")
    {
        ; See: https://www.autohotkey.com/docs/commands/PostMessage.htm#Examples
        ; 0x0112 = WM_SYSCOMMAND -- 0xF170 = SC_MONITORPOWER
        ; 2 is "turn-off" and 1 is apparently low-power (can't confirm tho)
        SendMessage 0x0112, 0xF170, 2,, "ahk_class Progman"
    }
}


; Make use of the built-in ShutDown function:
; https://www.autohotkey.com/docs/v1/lib/Shutdown.htm
_PowerControl_ShutDown(mode) {
    Loop
    {
        ShutDown(mode)
        Sleep 3000
    }
}

PowerControl_ShutDown() {
    _PowerControl_ShutDown(9)
}

PowerControl_Reboot() {
    _PowerControl_ShutDown(2)
}

PowerControl_Logoff() {
    _PowerControl_ShutDown(0)
}

; Calling into Windows dll powrprof
_PowerControl_Suspend(mode) {
    DllCall("powrprof.dll\SetSuspendState", "Int", mode, "Int", 0, "Int", 0)
}

PowerControl_Standby() {
    _PowerControl_Suspend(0)
}

PowerControl_Hibernate() {
    _PowerControl_Suspend(1)
}

PowerControl_Screensaver() {
    ; https://learn.microsoft.com/en-us/windows/win32/menurc/wm-syscommand#parameters
    ; 0x0112 = WM_SYSCOMMAND -- 0xF140 = SC_SCREENSAVE
    SendMessage 0x0112, 0xF140, 0,, "ahk_class Progman"
}

; This doesn't work well, It turns the Screen back on.
; But `PowerControl_DisplayOff` already works pretty well like that!
; PowerControl_SecureScreensaver() {
; 	PowerControl_Screensaver()
;     PowerControl_LockWorkStation()
; }

PowerControl_LockWorkStation() {
	Run "rundll32 user32,LockWorkStation"
}
