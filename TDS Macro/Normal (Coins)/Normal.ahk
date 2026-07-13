#Requires AutoHotkey v2.0
#SingleInstance Force
#Include "D:\TDS Macro\Functions\Functions.ahk"
#Include "D:\Macro Tools\OCR-2.0.0\Lib\OCR.ahk"
ListLines(False) ; disables line logging
KeyHistory(0)
ProcessSetPriority("H") ; priority to high "H"
SendMode("Event") ; enables delay to humanize clicks

CoordMode("Mouse", "Screen")
CoordMode("Pixel", "Screen")

; -- Optimization settings
SetKeyDelay(25, 15) ; 25 delay and 15 hold
SetMouseDelay(30)
SetDefaultMouseSpeed(5) ; 0 for instant 20 for very slow

; Wave Coordinates width and height
Wave_x := 633
Wave_y := 54
Wave_w := 102
Wave_h := 44
; -- Data -- n Var

PlotMap := Map(
    "Plot1", {x: 847, y: 528},
    "Plot2", {x: 1000, y: 534}
)
ButtonMap := Map(
    "ReadyButton", {x: 1044, y: 216},
    "SkipButton", {x: 1023, y: 197},
    "RestartButton", {x: 710, y: 878},
    "UpgradeButton", {x: 1145, y: 686,},
    "ReturnLobby", {x: 1101, y: 882}    
)

ColorMap := Map(
    "AffordableColor", 0x1E5C32,
    "RestartButtonColor", 0x23C84B,
    "ReturnLobbyC", 0x7F7F7F
)

FrostMode := {x: 1465, y: 584}
ReadyButton1 := {x: 1020, y: 337}

LastWave := ""
RawText := ""
; ArrowPos  = 892, 502 (x1 y1)
; ArrowPos = 968, 759 (x2 y2)
ArrowColor := 0x0FFF50
WaveCount           := 0
Match               := 1
Coins              := 141
CoinsPerMatch       := 141
ScriptStartTime     := 0
MatchStartTime      := 0
Version             := "1.0.3"
Toggle              := false
ArrowButton         := {x: 869, y: 784}
PurchasedUpgrades   := 0
ExpS                := 42
Exp1                := 42
ReadyButton_x       := ButtonMap["ReadyButton"].x
ReadyButton_y       := ButtonMap["ReadyButton"].y
SkipButton_x        := ButtonMap["SkipButton"].x
SkipButton_y        := ButtonMap["SkipButton"].y
RestartButton_x     := ButtonMap["RestartButton"].x
RestartButton_y     := ButtonMap["RestartButton"].y
UpgradeButton_x     := ButtonMap["UpgradeButton"].x
UpgradeButton_y     := ButtonMap["UpgradeButton"].y
ReturnLobby_x       := ButtonMap["ReturnLobby"].x
ReturnLobby_y       := Buttonmap["ReturnLobby"].y
ReturnLobbyColor := ColorMap["ReturnLobbyC"]
UpgradeColor := ColorMap["AffordableColor"]

TDSGui := Gui("+AlwaysOnTop -MaximizeBox", "TDS Overlay") ; Disabled resizing for a clean look
TDSGui.BackColor := "1F1F1F"

; --- Header Section ---
TDSGui.SetFont("s14 Bold cFFFFFF", "Segoe UI")
TDSGui.AddText("w220 Center xm y10", "TDS Normal Coin Grind")
TDSGui.SetFont("s8 cAAAAAA") ; Muted color for version
TDSGui.AddText("w220 Center y+2", "Version: " Version)

; --- Group 1: Match Status ---
TDSGui.SetFont("s10 Bold cFFFFFF", "Segoe UI")
TDSGui.AddGroupBox("w220 h105 xm y+15", "Match Status")
TDSGui.SetFont("s9 Norm")

; Inside GroupBox 1 (Using relative coordinates 'xp+X yp+Y')
GuiStatus := TDSGui.AddText("xp+15 yp+22 w190", "Status: Waiting")
GuiMatch  := TDSGui.AddText("y+6 w190", "Match: #" Match)
GuiWave   := TDSGui.AddText("y+6 w190", "Wave: " WaveCount)
GuiTime   := TDSGui.AddText("y+6 w190", "Time: 00:00")

; --- Group 2: Material / Earnings ---
TDSGui.SetFont("s10 Bold cFFFFFF")
TDSGui.AddGroupBox("w220 h85 xm y+15", "Material")
TDSGui.SetFont("s9 Norm")

; Inside GroupBox 2
GuiCoins  := TDSGui.AddText("xp+15 yp+22 w190", "Coins: " Coins)
GuiCoinsh := TDSGui.AddText("y+6 w190", "Coins/hour: Calculating...")
GuiExp    := TDSGui.AddText("y+6 w190", "Exp: " ExpS)

; --- Group 3: Controls & Instructions ---
TDSGui.SetFont("s10 Bold cFFFFFF")
TDSGui.AddGroupBox("w220 h100 xm y+15", "Instructions")
TDSGui.SetFont("s9 Norm cE0E0E0")

; Inside GroupBox 3
TDSGui.AddText("xp+15 yp+22 w190", "[Ctrl+Shift+F8] Suspend")
TDSGui.AddText("y+4 w190", "[Ctrl+Shift+R] Start / Pause")
TDSGui.AddText("y+4 w190", "[Ctrl+Shift+S] Stop -> Lobby")
GuiOCR := TDSGui.AddText("y+4 w190", "OCR Reads: " RawText)

; --- Footer Section ---
TDSGui.SetFont("s9 Bold cFFFFFF")
GuiRealTime := TDSGui.AddText("w220 Center xm y+20", "Script Time: 00:00:00")

; Let AHK calculate the required height automatically based on elements
TDSGui.Show("x25 y200 w250")



; Map: Pizza Party
; Mode: Pizza Party
global CurrentText := "Script Disabled"

^+F8:: {
    global CurrentText
    Suspend(-1)
    if A_IsSuspended {
        Title := "Script Status"
        Message := "SUSPENDED`nBinds are now suspended`n Press Ctrl+Shift+F8 to resume"
        CurrentText := "Script Disabled"
    } else {
        Title := "Script Status"
        Message := "RESUMED`nBinds are now active`n Press Ctrl+Shift+F8 to suspend"
        CurrentText := "Script Enabled"
    }
    ; Start the tooltip loop ONLY when the hotkey is pressed
    TrayTip(Message, Title, 1)
}

^+s:: {
    global ReturnLobby_x, ReturnLobby_y, ReturnLobbyColor, Toggle
    Toggle := !Toggle
    GuiStatus.Value := "Status: Script Ended.."
    if Toggle {
        loop {
            if PixelSearch(&FoundX, &FoundY, ReturnLobby_x - 10, ReturnLobby_y - 10, ReturnLobby_x + 10, ReturnLobby_y + 10, ReturnLobbyColor, 40) {
                break
            }
            Sleep(200)
        }
        MouseMove(ReturnLobby_x, ReturnLobby_y, 2)
        Sleep(200)
        MouseMove(1, 0, 0, "R")
        Sleep(200)
        Click("Down")
        Sleep(200)
        Click("Up")
        ExitApp
    }
}

^+r:: {
    global Toggle, ScriptStartTime, MatchStartTime
    Toggle := !Toggle
    if Toggle {
        GuiStatus.Value := "Status: Grinding..."
        SetTimer(UpdateMatchClock, 1000)
        if (WinExist("ahk_exe RobloxPlayerBeta.exe")) {
            WinActivate("ahk_exe RobloxPlayerBeta.exe")
            Sleep(800)
        }
        if (ScriptStartTime == 0) {
            ScriptStartTime := A_TickCount
        }
        ; Sleep(5000)
        Setup()
        Sleep(500)
        SetTimer(MainGrindLoop, -10)
    } else {
        GuiStatus.Value := "Status: Paused"
        Sleep(500)
        Reload()
    }
}


Setup() {
    ; GuiStatus.Value := "Status: Clicking the Ready Button"
    ; MouseMove(FrostMode.x, FrostMode.y, 1)
    ; Sleep(200)
    ; MouseMove(1, 0, 0, "R")
    ; Click("Down")
    ; Sleep(100)
    ; Click("Up")
    ; Sleep(1000)
    ; MouseMove(ReadyButton1.x, ReadyButton1.y, 1)
    ; Sleep(200)
    ; MouseMove(1, 0, 0, "R")
    ; Click("Down")
    ; Sleep(100)
    ; Click("Up")
    ; move character to preferred position
    GuiStatus.Value := "Status: Moving Character.."
    Sleep(1000)
    Send("{i down}")
    Sleep(750)
    Send("{i up}")

    Sleep(500)

    Send("{o down}")
    Sleep(500)
    Send("{o up}")

    Sleep(500)
    ; turn camera upwards
    MouseMove(A_ScreenWidth // 2, A_ScreenHeight // 2, 0)
    Click("Right Down")
    Sleep(200)

    MouseMove(0, 200, 0, "R")
    Sleep(200)
    Click("Right Up")
    Sleep(1000)

    ; anchored here
    
    Send("{w down}" "{shift down}")
    Sleep(700)
    Send("{w up}" "{shift up}")
}

MainGrindLoop() {
    global WaveCount, Match, Coins, ScriptStartTime
    loop {
        WaveCount := 0
        GuiWave.value := "Wave: " WaveCount
        GuiMatch.value := "Match: #" Match
        Sleep(2000)
        Grind()
        Sleep(500)
        loop {
            if PixelSearch(&FoundX, &FoundY, RestartButton_x - 30, RestartButton_y - 30, RestartButton_x + 30, RestartButton_y + 30, ColorMap["RestartButtonColor"], 30) {
                try {
                    Result := OCR.FromRect(RestartButton_x, RestartButton_y, 231, 31, {scale: 2, grayscale: 1})
                    Result.Highlight(2000)
                    ToolTip("Restart Button detected!")
                    SetTimer(() => ToolTip(), -2000)
                } catch Error as err {
                    TrayTip("Error: " err.Message, "ERROR", "3")
                }
                break
            }
        }
        GuiStatus.Value := "Status: Restarting Match.."
        MouseMove(RestartButton_x + 40, RestartButton_y + 10, 1)
        Sleep(300)
        MouseMove(1, 20, 0, "R")
        Sleep(300)
        Click("Down")
        Sleep(200)
        Click("Up")
        Sleep(2000)
    }
}

Grind() {
    global Match, Coins, WaveCount, MatchStartTime, Cap, ExpS, Exp1
    Attempts := 0
    if (Match > 1) {
        Sleep(6000)
    }
    GuiStatus.Value := "Status: Placing Brawler to Plot 1"
    Cap := 1
    Sleep(300)
    Send("{1}")
    Sleep(300)
    PlaceNextTower(1, 0, 0)
    Sleep(500)
    GuiStatus.Value := "Status: Upgrading Brawler (Plot 1)"
    Sleep(200)
    loop {
        if AffordableFunction(1, 1, 0, 0) || Attempts > 2 {
            break
        }
        Sleep(200)
        Click(A_ScreenWidth // 2, A_ScreenHeight // 2, 1)
        Attempts++
    }
    Sleep(500)
    Click(A_ScreenWidth // 2, A_ScreenHeight // 2)
    Sleep(2000)
    ;892, 502 (x1 y1) 
; ArrowPos = 968, 759 (x2 y2)
    if ImageSearch(&FoundX, &FoundY, 893, 511, 969, 902, "D:\TDS Macro\Normal (Coins)\GreenArrow.png") {
        if PixelSearch(&Px, &Py, FoundX, FoundY, FoundX + 30, FoundY + 30, ArrowColor, 50) {
            Sleep(4500)
        }
        else {
            ToolTip("Error: Arrow Color not Familiar!")
            SetTimer(() => Tooltip(), -3000)
            Sleep(4500)
        }
    } else {
        ToolTip("Error: Arrow not Matched with GreenArrow.png!")
        SetTimer(() => ToolTip(), -3000)
        Sleep(4500)
    }
    Sleep(500)
    GuiStatus.Value := "Status: Match Starting.."
    MatchStartTime := A_TickCount
    ; match starts
    WaveCount := 1
    GuiWave.Value := "Wave: " WaveCount
    Step2 := false
    Step3 := false
    Step4 := false
    Step5 := false
    Step6 := false
    Step7 := false

    loop {
        SetTimer(AutoSkip, 250)
        WaveCounter := GetCurrentWaveOCR()
        if (IsInteger(WaveCounter) && WaveCounter > 0 && WaveCounter < 40) {
                WaveCount := WaveCounter
                GuiWave.Value := "Wave: " WaveCount
        }
        ElapsedTimes := (A_TickCount - MatchStartTime) // 1000 ;
        if ((WaveCount == 2 || ElapsedTimes >= 8) && !Step2) {
            Cap := 2
            Attempts := 0
            GuiWave.Value := "Wave: " WaveCount
            GuiStatus.Value := "Status: Placing Brawler to Plot 2"
            Send("{1}")
            Sleep(300)
            PlaceNextTower(1, 0, 40) ; +40 y level to placenext brawler since i dont want to write each plot 1by1
            Sleep(500)
            GuiStatus.Value := "Status : Upgrading Brawler (Plot 2)"
            Loop {
                if AffordableFunction(1, 1, 0, 40) || Attempts > 2 {
                        break
                }
                Sleep(400)
                Click(A_ScreenWidth // 2, A_ScreenHeight // 2)
                Sleep(100)
                Attempts++
            }
            Sleep(200)
            Step2 := true
        }
        if ((WaveCount == 3 || ElapsedTimes >= 19) && !Step3) {
            Cap := 3
            Attempts := 0
            GuiWave.Value := "Wave: " WaveCount
            GuiStatus.Value := "Status: Placing Brawler to Plot 3"
            Send("{1}")
            Sleep(300)
            PlaceNextTower(1, 0, 80)
            Sleep(900)
            GuiStatus.Value := "Status : Upgrading Brawler (Plot 3)"
            Loop {
                if AffordableFunction(1, 1, 0, 80) || Attempts > 2 {
                        break
                }
                Sleep(400)
                Click(A_ScreenWidth // 2, A_ScreenHeight // 2)
                Sleep(100)
                Attempts++
            }
            Sleep(200)
            Step3 := true
        }
        if ((WaveCount == 4 || ElapsedTimes >= 34) && !Step4) {
            Cap := 4    
            Attempts := 0
            GuiWave.Value := "Wave: " WaveCount
            GuiStatus.Value := "Status: Placing Brawler to Plot 4"
            Send("{1}")
            Sleep(300)
            PlaceNextTower(1, 0, 120)
            Sleep(900)
            GuiStatus.Value := "Status: Upgrading Brawler (Plot 4)"
            Loop {
                if AffordableFunction(1, 1, 0, 120) || Attempts > 3 {
                        break
                }
                Sleep(400)
                Click(A_ScreenWidth // 2, A_ScreenHeight // 2)
                Sleep(100)
                Attempts++
            }
            Sleep(5000)
            Cap := 5
            GuiStatus.Value := "Status: Placing Brawler to Plot 5"
            Send("{1}")
            Sleep(300)
            PlaceNextTower(1, 0, 160)
            Step4 := true
        }
        if ((WaveCount == 5 || ElapsedTimes >= 45) && !Step5) {
            Cap := 5
            Attempts := 0
            GuiWave.Value := "Wave: " WaveCount
            GuiStatus.Value := "Status: Upgrading Brawler (Plot 5)"
            Sleep (900)
            Loop {
                if AffordableFunction(1, 1, 0, 160) || Attempts > 4 {
                        break
                }
                Sleep(400)
                Click(A_ScreenWidth // 2, A_ScreenHeight // 2)
                Sleep(100)
                Attempts++
            }
            Sleep(2000)
            Cap := 6
            GuiStatus.Value := "Status: Placing Brawler to Plot 6"
            Send("{1}")
            Sleep(200)
            PlaceNextTower(2, 0, 0)
            Sleep(900)
            GuiStatus.Value := "Status: Upgrading Brawler (Plot 6)"
            Attempts := 0
            Loop {
                if AffordableFunction(2, 1, 0, 0) || Attempts > 4 {
                        break
                }
                Sleep(400)
                Click(A_ScreenWidth // 2, A_ScreenHeight // 2)
                Sleep(100)
                Attempts++
            }
            Sleep(900)
            Cap := 7
            Attempts := 0
            GuiStatus.Value := "Status: Placing Brawler to Plot 7"
            Send("{1}")
            Sleep(200)
            PlaceNextTower(2, 0, 40)
            Sleep(2500)
            GuiStatus.Value := "Status: Upgrading Brawler (Plot 7)"
            Sleep(1000)
            Loop {
                if AffordableFunction(2, 1, 0, 40) || Attempts > 4 {
                        break
                }
                Sleep(400)
                Click(A_ScreenWidth // 2, A_ScreenHeight // 2)
                Sleep(100)
                Attempts++
            }
            Step5 := true
        }
        if ((WaveCount == 6 || ElapsedTimes >= 58) && !Step6) {
            Cap := 8
            Attempts := 0
            GuiWave.Value := "Wave " WaveCount
            Sleep(300)
            GuiStatus.Value := "Status: Placing Brawler to Plot 8"
            Send("{1}")
            Sleep(300)
            PlaceNextTower(2, 0, 80)
            Sleep(1000)
            GuiStatus.Value := "Status: Upgrading Brawler (Plot 8)"
            Loop {
                if AffordableFunction(2, 1, 0, 80) || Attempts > 4 {
                        break
                }
                Sleep(100)
                Click(A_ScreenWidth // 2, A_ScreenHeight // 2)
                Sleep(100)
                Attempts++
            }
            Sleep(1000)
            Cap := 9
            Attempts := 0
            GuiStatus.Value := "Status: Placing Brawler to PLot 9"
            Send("{1}")
            Sleep(200)
            PlaceNextTower(2, 0, 120)
            Sleep(900)
            GuiStatus.Value := "Status: Uprgading Brawler (Plot 9)"
            Loop {
                if AffordableFunction(2, 1, 0, 120) || Attempts > 5 {
                        break
                }
                Sleep(100)
                Click(A_ScreenWidth // 2, A_ScreenHeight // 2)
                Sleep(100)
                Attempts++
            }
            Sleep(3500)
            Cap := 10
            Attempts := 0
            GuiStatus.Value := "Status: Placing Brawler to Plot 10"
            Send("{1}")
            Sleep(200)
            PlaceNextTower(2, 0, 160)
            Sleep(500)
            GuiStatus.Value := "Status: Upgrading Brawler (Plot 10)"
            Sleep(1000)
            Loop {
                if AffordableFunction(2, 1, 0, 160) || Attempts > 3 {
                        break
                }
                    Sleep(100)
                    Click(A_ScreenWidth // 2, A_ScreenHeight // 2)
                    Sleep(100)
                    Attempts++
            }
            Sleep(500)
            Step6 := true
        }
        if ((WaveCount == 7 || ElapsedTimes >= 75) && !Step7) {
            GuiStatus.Value := "Status: Skipping Waves.."
            Step7 := true
        }
        if (ElapsedTimes >= 120) {
            WaveCount := 8
            GuiWave.Value := "Wave " WaveCount
            Match++
            ExpS := Match * Exp1
            GuiExp.Value := "Exp: " ExpS
            Coins := Match * CoinsPerMatch
            GuiCoins.Value := "Coins: " Coins
            TotalHoursRunning := (A_TickCount - ScriptStartTime) / 3600000 
            TotalCoins := 0
            if (TotalHoursRunning > 0) {    
                TotalCoins := Floor(Coins / TotalHoursRunning)
            }
            GuiCoinsh.Value := "Coins/hour: " TotalCoins
            Sleep(3000)
            GuiStatus.Value := "Status: Match Finished!"
            break
        }
    SetTimer(AutoSkip, 0)
    } 
}

PlaceNextTower(PlotNumber, AdjustmentX, AdjustmentY) {
    Target := "Plot" . PlotNumber
    if (PlotMap.Has(Target)) {
        X := PlotMap[Target].x + AdjustmentX
        Y := PlotMap[Target].y + AdjustmentY
        MouseMove(X, Y, 0)
        Sleep(200)
        MouseMove(1, 0, 1, "R")
        Sleep(200)
        Click("Down")
        Sleep(150)
        Click("Up")
    }
}

AutoSkip() {
    global WaveCount, GuiWave
    SkipButtonFunction(&WaveCount, ButtonMap["SkipButton"], GuiWave)
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

AffordableFunction(PlotNumber, Amount, AdjustmentX, AdjustmentY) {
    global PurchasedUpgrades, UpgradeButton_x, UpgradeButton_y, UpgradeColor, Cap
    TargetPlot := "Plot" . PlotNumber
    if (!PlotMap.Has(TargetPlot)) {
        return 
    }
    PlotX := PlotMap[TargetPlot].x + AdjustmentX
    PlotY := PlotMap[TargetPlot].y + AdjustmentY

    MouseMove(PlotX, PlotY, 1)  
    Sleep(115)  
    MouseMove(1, 0, 0, "R")
    Sleep(50)
    Click("Down")
    Sleep(100)
    Click("Up")

    Sleep(100)
    if PixelSearch(&FoundX, &FoundY, UpgradeButton_x-10, UpgradeButton_y-10, UpgradeButton_x+10, UpgradeButton_y+10, UpgradeColor, 30) {
        Loop Amount {
            Send("{e}")
            Sleep(950)
            return true
        }
    }
    return false
}

GetCurrentWaveOCR() {
    global Wave_x, Wave_y, Wave_h, Wave_w, LastWave, RawText, GuiOCR
    Try {
        Found := OCR.FromRect(Wave_x, Wave_y, Wave_w, Wave_h, {scale: 2, grayscale: 1})
        found.Highlight(2000)

        RawText := Found.Text
        ; (\d+) captures one or more digit to save to match[1]
        ; \s* looks for zero or spaces  
        ;  / looks for slash
        ; m for multi line matching because of wave: below is numbers
        ToolTip("OCR Raw Text Detected: '" RawText "'")
        GuiOCR.Value := "OCR Reads: " RawText 
        SetTimer(() => ToolTip(), -3000)
        if RegExMatch(RawText, "m)(\d+)\s*/", &RegMatch) {
            LastWave := Integer(RegMatch[1])
            return LastWave ; returns a number value of the digit before the slash
        } else {
            ; OCR read text, but it didn't match the expected format
            ToolTip("OCR failed to translate wave number from text: '" RawText "'")
            SetTimer(() => ToolTip(), -3000)
        }
        } Catch Error as err {
            TrayTip("OCR Crashed: " err.Message, "OCR Status", "3")
        }
    return 0
}

F3:: {
    global Wave_h, Wave_w, Wave_x, Wave_y
    try {
        Result := OCR.FromRect(Wave_x, Wave_y, Wave_w, Wave_h, {scale: 2, grayscale: 1})
        Result.Highlight(2000)
        ToolTip("OCR Sees: '" Result.Text "'")
    } catch Error as err {
        MsgBox("Error Running OCR: " err.Message)
    }
}