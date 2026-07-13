#NoEnv
#SingleInstance, Force
SendMode, Input ; reliable mode to send inputs
SetBatchLines, 10 ; to speed the script (CPU usage though)
SetWorkingDir, %A_ScriptDir%
CoordMode, Mouse, Screen ;using screen because tds

; -- Optimization settings --
SetMouseDelay, 30 ; SetMouseDelay, input
SetKeyDelay, 30, 15 ; SetKeyDelay, Delay, PressDuration

; Variables/Coordinates/Initialization
ReadyButton := {x: 1045, y: 217}
Plot1 := {x: 1173, y: 397}
Plot2 := {x: 1119, y: 401}
Plot3 := {x: 1211, y: 290}
SkipButton := {x: 1032, y: 211}
RestartButton := {x: 827, y: 865}
UpgradeButton := {x: 1145, y: 686}
global AffordableColor := 0x1E5C32
global RestartButtonColor := 0x23C84B
global Cap := "" ; Cap: CurrentActivePlot
global WaveCount := 1
global Match := 1
global GemsPerMatch = 43
global Gems := 0
global ScriptStartTime := 0
global Version := "1.0.2"

Gui, +AlwaysOnTop
Gui, Color, 1F1F1F, 2D2D2D
Gui, Font, s10 cFFFFFF, Segoe UI

Gui, Font, s12 cFFFFFF, Segoe UI
Gui, Add, Text, x40 y10 w220 vGuiTitle, TDS Hardcore Gem Grind
Gui, Font, s7
Gui, Add, Text, x90 y30 w220 vGuiVersion, Version: (%Version%)
Gui, Font, s10
Gui, Add, Text, x15 y50 w220 vGuiStatus, Status: Waiting...
Gui, Add, Text, x15 y75 w220 vGuiMatch, Match: #%Match%
Gui, Add, Text, x15 y100 w220 vGuiWave, Wave: %WaveCount%
Gui, Add, text, x15 y125 w220 vGuiTime, Time: 00:00
Gui,Font, s12 cFFFFFF, Segoe UI
Gui, Add, Text, x95 y150 w220 vSubTitle, Material
Gui, Font, s10 cFFFFFF, Segoe UI
Gui, Add, Text, x15 y175 w220 vGuiGems, Gems: 43
Gui, Add, Text, x15 y200 w220 vGuiGemh, Gems/hour: Calculating...
Gui,Font, s12 cFFFFFF, Segoe UI
Gui, Add, Text, x85 y225 w220 vSubTitle2, Instruction
Gui, Font, s10 cFFFFFF, Segoe UI
Gui, Add, Text, x15 y260 w220 vText, Ctrl+Shift+F8 to suspend script
Gui, Add, Text, x15 y280 w220 vText2, Ctrl+Shift+S to start/pause script
Gui, Add, Text, x15 y310 w220 vGuiRealTime, Script Time: 00:00:00

Gui, Show, x200 y200 w250 h350, TDS Overlay


SetTimer, MoveToolTip,10
SetTimer, RemoveToolTip, -5000
return

; --- Suspend ---
^+F8::
    Suspend, Permit
    Suspend
    if (A_IsSuspended) {
        Title := "Script Status"
        Message := "SUSPENDED`nBinds are now disabled.`nCrtl+Shift+F8 to resume!"
        CurrentText := "Script DISABLED"
    } else {
        Title := "Script Status"
        Message := "ACTIVE`nBinds are now Enabled.`nCrtl+Shift+F8 to pause!"
        CurrentText := "Script ENABLED"
    }

    TrayTip, %Title%, %Message%, 2, 1
return

; --- ToolTip Logic ---
^+S::
    if (Toggle := !Toggle) {
        GuiControl,, GuiStatus, Status: Grinding...
        SetTimer, UpdateMatchClock, 1000 ; updates every 1s or 1000ms
        SetTimer, MoveToolTip, 10
        SetTimer, RemoveToolTip, -1000
        Sleep, 1000
        if WinExist("ahk_exe RobloxPlayerBeta.exe") {
            WinActivate, ahk_exe RobloxPlayerBeta.exe
            Sleep, 800
        }
        if (ScriptStartTime = 0) {
            ScriptStartTime := A_TickCount
        }
        Gosub, Setup
        Sleep, 1000
        SetTimer, MainGrindLoop, -10 ; inputs the setup function to position the character after match just started
    } else {
        GuiControl,, GuiStatus, Status: Paused...
        SetTimer, MoveToolTip, 10
        SetTimer, RemoveToolTip, -1000
        Sleep, 500
        Reload
    }
return
MoveToolTip:
    ; This puts the text right next to your mouse cursor
    ToolTip, %CurrentText%
return

RemoveToolTip:
    ; This turns off the timer and deletes the tooltip after 5 seconds
    SetTimer, MoveToolTip, Off
    ToolTip
return

; --- Setup (Position of Character after match just started) ---
Setup:
    ; make sure to restart the camera
    Send {i down}
    Sleep 1000
    Send {i Up}
    Sleep 500 ; delay
    ;zooms out
    Send {o down}
    Sleep, 1000
    Send {o Up}
    Sleep, 500 ; delay
    ;moving the char
    Send {a down}
    Sleep, 500
    Send {a Up}
    Sleep, 500 ; delay
    Send {s down}
    Sleep, 2500
    Send, {s Up}
    Sleep, 500 ; delay
    ; adjusting the screen
    MouseMove, A_ScreenWidth/2, A_ScreenHeight/2, 0
    Sleep , 200 ; delay
    Click, Right Down ; to reposition the mouse cursor because its in the dead center of the screen
    Sleep, 200 ; delay
    ; MouseMove, X, Y, Speed, Relative
    ; X = 0 (Don't move left/right)
    ; Y = 300 (Move downwards 300 pixels)
    ; Speed = 10 (Slightly slowed down so the game engine processes the camera sweep)
    ; R = Relative to current mouse position
    ; move screen upwards
    MouseMove, 0, 300, 10, R
    Sleep, 200
    Click, Right Up
    Sleep, 500
    return

    MainGrindLoop:
        Loop {
            WaveCount := 1
            GuiControl,, GuiWave, Wave: %WaveCount%
            GuiControl,, GuiMatch, Match: #%Match%
            GoSub, Grind
            Sleep, 1000
            MouseMove, % RestartButton.x, % RestartButton.y, 7
            Sleep, 300
            MouseMove, 1, 0, 0, R
            Sleep, 200
            Click, Down
            Sleep, 200
            Click, Up

            Sleep, 3000 ; 3 seconds
        }
    return

Grind:
    MouseMove, % ReadyButton.x, % ReadyButton.y, 7
    Sleep, 400
    MouseMove, 1, 0, 0, R ; move 1 pixel relative to the right
    Sleep, 200
    Click
    Sleep, 3000 ; wait for match to load
    MatchStartTime := A_TickCount
    ; Step 1: Wait for suffecient money to afford minigunner ($1850) starts at ($900) -- > Minigunner 1
    Cap := Plot1
    Loop {
        Gosub, SkipButtonFunction
        Sleep, 400
        if (WaveCount >= 4) {
            Break
        }
    }
    Sleep, 2000
    Send, {1} ; minigunner
    Sleep 800 ; waits for 800ms to processs input so if lag theres a delay
    MouseMove, % Plot1.x, % Plot1.y, 7
    Sleep 100
    MouseMove, 1, 0, 0, R
    Sleep 100
    Click, Down
    Sleep, 150
    Click, Up
    Sleep, 200
    ; Upgrade to level 2
    PurchasedUpgrades := 0
    MouseMove, % Plot1.x, % Plot1.y, 7
    Sleep, 400
    MouseMove, 1, 0, 0, R
    Sleep 200
    Click Down
    Sleep 100
    Click Up
    Loop {
        Gosub, AffordableFunction
        if (PurchasedUpgrades >= 2) {
            Break
        }
        Gosub, SkipButtonFunction
        Sleep, 150
    }
    ; click to a neutral place so upgrade button dissapears
    MouseMove, A_ScreenWidth/2, 100, 7
    Sleep, 200
    Click
    Sleep, 500
    ; ============== Step 2: Minigunner 2 yes yes ===========================
    Cap := Plot2
    Loop {
        Gosub, SkipButtonFunction
        Sleep, 400
        if (WaveCount >= 9) {
            Break
        }
    }
    Send, {1} ; minigunner
    Sleep 800 ; waits for 800ms to processs input so if lag theres a delay
    MouseMove, % Plot2.x, % Plot2.y, 7
    Sleep 100
    MouseMove, 1, 0, 0, R
    Sleep 100
    Click, Down
    Sleep, 150
    Click, Up
    Sleep, 200
    ; ugrade to level 2
    PurchasedUpgrades := 0
    Sleep, 200
    MouseMove, % Plot2.x, % Plot2.y, 7
    Sleep, 400
    MouseMove, 1, 0, 0, R
    Sleep 200
    Click Down
    Sleep 100
    Click Up
    Loop {
        Gosub, AffordableFunction
        if (PurchasedUpgrades >= 2) {
            Break
        }
        Gosub, SkipButtonFunction
        Sleep, 150
    }
    MouseMove, A_ScreenWidth/2, 100, 7
    Sleep, 200
    Click
    Sleep, 500
    ; ============== Step 3: Minigunner 3 yes yes ===========================
    Cap := Plot3
    Loop {
        Gosub, SkipButtonFunction
        Sleep, 400
        if (WaveCount >= 13) {
            Break
        }
    }
    Send, {1} ; minigunner
    Sleep 800 ; waits for 800ms to processs input so if lag theres a delay
    MouseMove, % Plot3.x, % Plot3.y, 7
    Sleep 100
    MouseMove, 1, 0, 0, R
    Sleep 100
    Click, Down
    Sleep, 150
    Click, Up
    Sleep, 200
    ; ugrade to level 2
    PurchasedUpgrades := 0
    Sleep, 200
    MouseMove, % Plot3.x, % Plot3.y, 7
    Sleep, 400
    MouseMove, 1, 0, 0, R
    Sleep 200
    Click Down
    Sleep 100
    Click Up
    Loop {
        Gosub, AffordableFunction
        if (PurchasedUpgrades >= 2) {
            Break
        }
        Gosub, SkipButtonFunction
        Sleep, 150
    }
    MouseMove, A_ScreenWidth/2, 100, 7
    Sleep, 200 
    Click
    Sleep, 500
    ; restart match after wave 15
    Loop {
        Gosub, SkipButtonFunction
        Sleep, 400
        PixelSearch, FoundX, FoundY, RestartButton.x-20, RestartButton.y-20, RestartButton.x+20, RestartButton.y+20, RestartButtonColor, 40, Fast RGB
        if (ErrorLevel = 0) {
            Break
        }
    }
    Match++ ; to track the match count
    Gems := Match * GemsPerMatch
    GuiControl,, GuiGems, Gems: %Gems%

    TotalHoursRunning := (A_TickCount - ScriptStartTime) / 3600000 ; ms into hours
    TotalGems := 0
    if (TotalHoursRunning > 0) {
        TotalGems := Floor(Gems / TotalHoursRunning)
    }
    GuiControl,, GuiGemh, Gems/hour: %TotalGems%
return


SkipButtonFunction:
; searches 3 pixel, since hover rgb stuffs like that to be precise and make a prediction ; 20 shades of difference
    PixelSearch, FoundX, FoundY, SkipButton.x-5, SkipButton.y-5, SkipButton.x+5, SkipButton.y+5, 0x27FC00, 20, Fast RGB
    if (ErrorLevel = 0) { ; something similar is found then
        WaveCount++
        GuiControl,, GuiWave, Wave: %WaveCount%
        Sleep, 200 ; delay
        MouseMove, % SkipButton.x, % SkipButton.y, 7
        Sleep 400
        MouseMove, 1, 0, 0, R
        Sleep 200
        Click, Down
        Sleep, 200
        Click, Up   
        StillGreen := ""
        Loop {
            PixelSearch, StillGreen, _, SkipButton.x-5, SkipButton.y-5, SkipButton.x+5, SkipButton.y+5, 0x27FC00, 20, Fast RGB
            if (StillGreen != 0) { ; 0 means it found it, non-zero means it's gone
                break
            }
            Sleep, 200
        }
        Sleep, 1200 ; delay
    }
    Sleep, 200
return

AffordableFunction:
    MouseMove, % Cap.x, % Cap.y, 4  
    Sleep, 150
    MouseMove, 1, 0, 0, R
    Sleep, 150
    Click, Down
    Sleep, 100
    Click, Up
    Sleep, 250
    PixelSearch, FoundX, FoundY, UpgradeButton.x-10, UpgradeButton.y-10, UpgradeButton.x+10, UpgradeButton.y+10, AffordableColor, 30, Fast RGB
        if (ErrorLevel = 0) {
            ; green
            Send {e} ; upgrade
            Sleep, 500
            PurchasedUpgrades++
        }
return

UpdateMatchClock:
;-- Match Clock --
    ElapsedTime := A_TickCount - MatchStartTime
    TotalSeconds := Floor(ElapsedTime / 1000)
    Minutes := Floor(TotalSeconds / 60)
    Seconds := Mod(TotalSeconds, 60)
    FormattedTime := Format("{:02}:{:02}", Minutes, Seconds)
    GuiControl,, GuiTime, Time: %FormattedTime%
    if (StrLen(Minutes) = 1)
        Minutes := "0" . Minutes
    if (StrLen(Seconds) = 1)
        Seconds := "0" . Seconds
    GuiControl,, GuiTime, Time: %Minutes%:%Seconds%
    ; -- Script Time --
    if (ScriptStartTime > 0) {
        TotalScriptMS := A_TickCount - ScriptStartTime
        TotalScriptSeconds := Floor(TotalScriptMS / 1000)

        ScriptHours := Floor(TotalScriptSeconds / 3600)
        ScriptMinutes := Floor(Mod(TotalScriptSeconds, 3600) / 60) ; for example: if secs = 3920 then 3920 - 3600 = 320 after that 320 / 60 = 5,33333333 after that floor(5.33333333) = 5 minutes
        ScriptSeconds := Mod(TotalScriptSeconds, 60) ; 3920 / 60 = 65,333.. after that 65 * 60 = 3900 meaning 3920 - 3900 = 20 seconds (remainder)
        FormattedScriptTime := Format("{:02}:{:02}:{:02}", ScriptHours, ScriptMinutes, ScriptSeconds) ; using 2 digits (:02)
        if (StrLen(ScriptHours) = 1) {
            ScriptHours := "0" . ScriptHours
        }
        GuiControl,, GuiRealTime, Script Time: %FormattedScriptTime%
    }
return


;ok so this is the flow:
;- player clicks ready
;- player puts minigguner 1 and upgrades to level 2
;- player puts minigunner 2 and upgrades to level 2
;- player puts minigunner 3 and upgrades to level 2
;- in the middle of that all theres a skip button which i have to press
;- after that the match ends in roughly 3 minutes and player press the restart match button
;- loop 1 ended, and then continue the next loop
; wave 1: 13s
; wave 2: 14s
; wave 3: 15s
; wave 4: 20s

; wave 4: minigunner level 1 (wait for 1000ms)
; wave 7: minigunner 2nd upgrade unlocked
; wave 9: second minigunner
; wave 10: second minigunner level 1
; wave 11: second minigunner 2nd upgrade unlocked
; wave 13: third minigunner level 1
; wave 14: third minigunner level 2
; auto skip until wave 15