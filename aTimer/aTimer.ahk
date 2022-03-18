; aTimer - aTimer.ahk
; author: eric
; created: 2021 9 14

aTimer_menu(){
    InputBox, minutes, aTimer, Set a timer in ... Minutes?, , 240, 120
    minutes := Trim(minutes)
    If !IsNumber(minutes) {
        if !minutes
            return
        a2tip("How much is """ minutes """ Minutes?!? ...")
        return
    }

    InputBox, what_to_do, aTimer, What to do in %minutes% Minutes?, , 240, 120
    what_to_do := Trim(what_to_do)
    if !what_to_do
        return

    global _aTimer_what_to_do
    _aTimer_what_to_do := what_to_do
    SetTimer, aTimer_exec, % minutes * 60000
}

aTimer_exec() {
    SetTimer, aTimer_exec, Off
    global _aTimer_what_to_do
    app := "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
    Run, %app% %_aTimer_what_to_do%
}

; https://mynoise.net/NoiseMachines/windSeaRainNoiseGenerator.php
