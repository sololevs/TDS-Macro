#Requires AutoHotkey v2.0
#SingleInstance Force

;  -- Functions for TDS --

; Skip Button
SkipButtonFunction(&WaveCount, SkipButton, GuiWave) {
    if PixelSearch(&FoundX, &FoundY, SkipButton.x-5, SkipButton.y-5, SkipButton.x+5, SkipButton.y+5, 0x27FC00, 20) {
        WaveCount++
        GuiWave.Value := "Wave: " WaveCount
        Sleep(200) 
        MouseMove(SkipButton.x, SkipButton.y, 1)
        Sleep(400)
        MouseMove(1, 0, 0, "R")
        Sleep(200)
        Click("Down")
        Sleep(200)
        Click("Up")   
        
        ; the pixelsearch doesnt need foundX and foundY because i said so
        loop {
            if !PixelSearch(&_, &_, SkipButton.x-5, SkipButton.y-5, SkipButton.x+5, SkipButton.y+5, 0x27FC00, 20) {
                break
            }
            Sleep(200)
        }
        Sleep(1200) 
    }
    Sleep(200)
}

; Upgrade detection (Affordable or not)

; Cap = Current Active Plot

; ; Timer (If needed)
; UpdateMatchClock(MatchStartTime, ScriptStartTime, GuiTime, GuiRealTime) {
;     ElapsedTime := A_TickCount - MatchStartTime
;     TotalSeconds := Floor(ElapsedTime / 1000)
;     Minutes := Floor(TotalSeconds / 60)
;     Seconds :=  Mod(TotalSeconds, 60)
    
;     FormattedTime := Format("{:02}:{:02}", Minutes, Seconds)
;     GuiTime.Value := "Time: " FormattedTime
    
;     if (ScriptStartTime > 0) {
;         TotalScriptMS := A_TickCount - ScriptStartTime
;         TotalScriptSeconds := Floor(TotalScriptMS / 1000)

;         ScriptHours := Floor(TotalScriptSeconds / 3600)
;         ScriptMinutes := Floor((Mod(TotalScriptSeconds, 3600)) / 60) 
;         ScriptSeconds := Mod(TotalScriptSeconds, 60)
;         FormattedScriptTime := Format("{:02}:{:02}:{:02}", ScriptHours, ScriptMinutes, ScriptSeconds)
;         GuiRealTime.Value := "Script Time: " FormattedScriptTime
;     }
; }

; Safe Click

RegisterClick(x := "", y := "") {
    if (x != "" && y != "") {
        MouseMove(x, y, 0)
    }
    MouseMove(1, 0, 0, "R")
    Click("Down")
    Sleep(30)
    Click("Up")
}