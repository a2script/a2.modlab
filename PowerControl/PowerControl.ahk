; PowerControl - PowerControl.ahk
; author: eric
; created: 2022 10 7

PowerControl_DisplayOff() {
    If (PowerControl_DisplayOffTimeout > 0)
    {
        SplashImage,,b1 cwFFFFc0 FS9 WS700 w400, lng_pc_DoDisplaySleep
        now := A_TickCount
        Loop
        {
            Input, this_key, V M T%PowerControl_DisplayOffTimeout% I L1
            If (this_key == Chr(27) OR ErrorLevel == "Timeout" )
                break

            If ((A_TickCount - now) / 1000 >= PowerControl_DisplayOffTimeout)
            {
                ErrorLevel := "Timeout"
                break
            }
        }
        SplashImage, Off
    }

    If (this_key <> Chr(27) OR ErrorLevel == "Timeout")
    {
        ; 0x0112 = WM_SYSCOMMAND
        ; 0xF170 = SC_MONITORPOWER
        SendMessage, 0x112, 0xF170, 1,, ahk_class Progman
    }
}