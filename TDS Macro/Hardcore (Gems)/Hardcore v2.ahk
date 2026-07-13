#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode("Input")
CoordMode("Mouse", "Screen")

; -- Optimization settings --
SetMouseDelay(30)
SetKeyDelay(30, 15)

; --- Coordinates & Variables ---
ReadyButton     := {x: 1045, y: 217}
Plot1           := {x: 1173, y: 397}
Plot2           := {x: 1119, y: 401}
Plot3           := {x: 1211, y: 290}
SkipButton      := {x: 1032, y: 211}
RestartButton   := {x: 827, y: 865}
UpgradeButton   := {x: 1145, y: 686}

AffordableColor    := 0x1E5C32
RestartButtonColor := 0x23C84B
Cap                := "" 
WaveCount          := 1
Match              := 1
GemsPerMatch       := 43
Gems               := 0
ScriptStartTime    := 0
MatchStartTime     := 0
Version            := "1.0.2"
Toggle             := false
CurrentText        := "Script DISABLED"
PurchasedUpgrades  := 0

; --- Modern v2 GUI Setup ---
TDSGui := Gui("+AlwaysOnTop", "TDS Overlay")
TDSGui.BackColor := "1F1F1F"

TDSGui.SetFont("s12 cFFFFFF", "Segoe UI")
TDSGui.AddText("x40 y10 w220", "TDS Hardcore Gem Grind")
TDSGui.SetFont("s7")
TDSGui.AddText("x90 y30 w220", "Version: (" Version ")")

TDSGui.SetFont("s10")
GuiStatus   := TDSGui.AddText("x15 y50 w220", "Status: Waiting...")
GuiMatch    := TDSGui.AddText("x15 y75 w220", "Match: #" Match)
GuiWave     := TDSGui.AddText("x15 y100 w220", "Wave: " WaveCount)
GuiTime     := TDSGui.AddText("x15 y125 w220", "Time: 00:00")

TDSGui.SetFont("s12")
TDSGui.AddText("x95 y150 w220", "Material")
TDSGui.SetFont("s10")
GuiGems     := TDSGui.AddText("x15 y175 w220", "Gems: 43")
GuiGemh     := TDSGui.AddText("x15 y200 w220", "Gems/hour: Calculating...")

TDSGui.SetFont("s12")
TDSGui.AddText("x85 y225 w220", "Instruction")
TDSGui.SetFont("s10")
TDSGui.AddText("x15 y260 w220", "Ctrl+Shift+F8 to suspend script")
TDSGui.AddText("x15 y280 w220", "Ctrl+Shift+S to start/pause script")
GuiRealTime := TDSGui.AddText("x15 y310 w220", "Script Time: 00:00:00")

TDSGui.Show("x200 y200 w250 h350")

; --- Hotkeys ---

; Suspend Script
^+F8:: {
    global CurrentText
    Suspend(-1) ; Toggles suspend state
    if A_IsSuspended {
        Title := "Script Status"
        Message := "SUSPENDED`nBinds are now disabled.`nCrtl+Shift+F8 to resume!"
        CurrentText := "Script DISABLED"
    } else {
        Title := "Script Status"
        Message := "ACTIVE`nBinds are now Enabled.`nCrtl+Shift+F8 to pause!"
        CurrentText := "Script ENABLED"
    }
    TrayTip(Message, Title, 1)
}

; Start / Pause Toggle
^+S:: {
    global Toggle, ScriptStartTime
    Toggle := !Toggle
    if Toggle {
        GuiStatus.Value := "Status: Grinding..."
        SetTimer(UpdateMatchClock, 1000)
        SetTimer(MoveToolTip, 10)
        SetTimer(RemoveToolTip, -1000)
        Sleep(1000)
        
        if WinExist("ahk_exe RobloxPlayerBeta.exe") {
            WinActivate("ahk_exe RobloxPlayerBeta.exe")
            Sleep(800)
        }
        if (ScriptStartTime == 0) {
            ScriptStartTime := A_TickCount
        }
        Setup()
        Sleep(1000)
        SetTimer(MainGrindLoop, -10)
    } else {
        GuiStatus.Value := "Status: Paused..."
        SetTimer(MoveToolTip, 10)
        SetTimer(RemoveToolTip, -1000)
        Sleep(500)
        Reload()
    }
}

; --- Functions (Replaced GoSubs) ---

MoveToolTip() {
    ToolTip(CurrentText)
}

RemoveToolTip() {
    SetTimer(MoveToolTip, 0)
    ToolTip()
}

Setup() {
    Send("{i down}")
    Sleep(1000)
    Send("{i up}")
    Sleep(500) 
    
    Send("{o down}")
    Sleep(1000)
    Send("{o up}")
    Sleep(500) 
    
    Send("{a down}")
    Sleep(500)
    Send("{a up}")
    Sleep(500) 
    
    Send("{s down}")
    Sleep(2500)
    Send("{s up}")
    Sleep(500) 
    
    MouseMove(A_ScreenWidth // 2, A_ScreenHeight // 2, 0)
    Sleep(200) 
    Click("Right Down") 
    Sleep(200) 
    
    MouseMove(0, 300, 10, "R")
    Sleep(200)
    Click("Right Up")
    Sleep(500)
}

MainGrindLoop() {
    global WaveCount, Match, Gems, ScriptStartTime
    loop {
        WaveCount := 1
        GuiWave.Value := "Wave: " WaveCount
        GuiMatch.Value := "Match: #" Match
        Grind()
        Sleep(1000)
        
        MouseMove(RestartButton.x, RestartButton.y, 7)
        Sleep(300)
        MouseMove(1, 0, 0, "R")
        Sleep(200)
        Click("Down")
        Sleep(200)
        Click("Up")

        Sleep(3000)
    }
}

Grind() {
    global Match, Gems, WaveCount, Cap, MatchStartTime
    MouseMove(ReadyButton.x, ReadyButton.y, 7)
    Sleep(400)
    MouseMove(1, 0, 0, "R")
    Sleep(200)
    Click()
    Sleep(3000) 
    MatchStartTime := A_TickCount
    
    ; Step 1: Minigunner 1
    Cap := Plot1
    loop {
        SkipButtonFunction()
        Sleep(400)
        if (WaveCount >= 4) {
            break
        }
    }
    Sleep(2000)
    Send("{1}") 
    Sleep(800) 
    MouseMove(Plot1.x, Plot1.y, 7)
    Sleep(100)
    MouseMove(1, 0, 0, "R")
    Sleep(100)
    Click("Down")
    Sleep(150)
    Click("Up")
    Sleep(200)
    
    ; Upgrade to level 2
    global PurchasedUpgrades := 0
    MouseMove(Plot1.x, Plot1.y, 7)
    Sleep(400)
    MouseMove(1, 0, 0, "R")
    Sleep(200)
    Click("Down")
    Sleep(100)
    Click("Up")
    loop {
        AffordableFunction()
        if (PurchasedUpgrades >= 2) {
            break
        }
        SkipButtonFunction()
        Sleep(150)
    }
    MouseMove(A_ScreenWidth // 2, 100, 7)
    Sleep(200)
    Click()
    Sleep(500)
    
    ; ============== Step 2: Minigunner 2 ===========================
    Cap := Plot2
    loop {
        SkipButtonFunction()
        Sleep(400)
        if (WaveCount >= 9) {
            break
        }
    }
    Send("{1}") 
    Sleep(800) 
    MouseMove(Plot2.x, Plot2.y, 7)
    Sleep(100)
    MouseMove(1, 0, 0, "R")
    Sleep(100)
    Click("Down")
    Sleep(150)
    Click("Up")
    Sleep(200)
    
    PurchasedUpgrades := 0
    Sleep(200)
    MouseMove(Plot2.x, Plot2.y, 7)
    Sleep(400)
    MouseMove(1, 0, 0, "R")
    Sleep(200)
    Click("Down")
    Sleep(100)
    Click("Up")
    loop {
        AffordableFunction()
        if (PurchasedUpgrades >= 2) {
            break
        }
        SkipButtonFunction()
        Sleep(150)
    }
    MouseMove(A_ScreenWidth // 2, 100, 7)
    Sleep(200)
    Click()
    Sleep(500)
    
    ; ============== Step 3: Minigunner 3 ===========================
    Cap := Plot3
    loop {
        SkipButtonFunction()
        Sleep(400)
        if (WaveCount >= 13) {
            break
        }
    }
    Send("{1}") 
    Sleep(800) 
    MouseMove(Plot3.x, Plot3.y, 7)
    Sleep(100)
    MouseMove(1, 0, 0, "R")
    Sleep(100)
    Click("Down")
    Sleep(150)
    Click("Up")
    Sleep(200)
    
    PurchasedUpgrades := 0
    Sleep(200)
    MouseMove(Plot3.x, Plot3.y, 7)
    Sleep(400)
    MouseMove(1, 0, 0, "R")
    Sleep(200)
    Click("Down")
    Sleep(100)
    Click("Up")
    loop {
        AffordableFunction()
        if (PurchasedUpgrades >= 2) {
            break
        }
        SkipButtonFunction()
        Sleep(150)
    }
    MouseMove(A_ScreenWidth // 2, 100, 7)
    Sleep(200) 
    Click()
    Sleep(500)
    
    ; Restart match check
    loop {
        SkipButtonFunction()
        Sleep(400)
        if PixelSearch(&FoundX, &FoundY, RestartButton.x-20, RestartButton.y-20, RestartButton.x+20, RestartButton.y+20, RestartButtonColor, 40) {
            break
        }
    }
    Match++ 
    Gems := Match * GemsPerMatch
    GuiGems.Value := "Gems: " Gems

    TotalHoursRunning := (A_TickCount - ScriptStartTime) / 3600000 
    TotalGems := 0
    if (TotalHoursRunning > 0) {
        TotalGems := Floor(Gems / TotalHoursRunning)
    }
    GuiGemh.Value := "Gems/hour: " TotalGems
}

; Functions [Ignore]
SkipButtonFunction() {
    global WaveCount
    if PixelSearch(&FoundX, &FoundY, SkipButton.x-5, SkipButton.y-5, SkipButton.x+5, SkipButton.y+5, 0x27FC00, 20) {
        WaveCount++
        GuiWave.Value := "Wave: " WaveCount
        Sleep(200) 
        MouseMove(SkipButton.x, SkipButton.y, 7)
        Sleep(400)
        MouseMove(1, 0, 0, "R")
        Sleep(200)
        Click("Down")
        Sleep(200)
        Click("Up")   
        
        loop {
            if !PixelSearch(&StillGreen, &_, SkipButton.x-5, SkipButton.y-5, SkipButton.x+5, SkipButton.y+5, 0x27FC00, 20) {
                break
            }
            Sleep(200)
        }
        Sleep(1200) 
    }
    Sleep(200)
}

AffordableFunction() {
    global PurchasedUpgrades
    MouseMove(Cap.x, Cap.y, 4)  
    Sleep(150)
    MouseMove(1, 0, 0, "R")
    Sleep(150)
    Click("Down")
    Sleep(100)
    Click("Up")
    Sleep(250)
    if PixelSearch(&FoundX, &FoundY, UpgradeButton.x-10, UpgradeButton.y-10, UpgradeButton.x+10, UpgradeButton.y+10, AffordableColor, 30) {
        Send("{e}") 
        Sleep(500)
        PurchasedUpgrades++
    }
}

UpdateMatchClock() {
    global MatchStartTime, ScriptStartTime
    ElapsedTime := A_TickCount - MatchStartTime
    TotalSeconds := Floor(ElapsedTime / 1000)
    Minutes := Floor(TotalSeconds / 60)
    Seconds :=  Mod(TotalSeconds, 60)
    
    FormattedTime := Format("{:02}:{:02}", Minutes, Seconds)
    GuiTime.Value := "Time: " FormattedTime
    
    if (ScriptStartTime > 0) {
        TotalScriptMS := A_TickCount - ScriptStartTime
        TotalScriptSeconds := Floor(TotalScriptMS / 1000)

        ScriptHours := Floor(TotalScriptSeconds / 3600)
        ScriptMinutes := Floor((Mod(TotalScriptSeconds, 3600)) / 60) 
        ScriptSeconds := Mod(TotalScriptSeconds, 60)
        FormattedScriptTime := Format("{:02}:{:02}:{:02}", ScriptHours, ScriptMinutes, ScriptSeconds)
        GuiRealTime.Value := "Script Time: " FormattedScriptTime
    }
}