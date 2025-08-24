#SingleInstance Force
SetWorkingDir A_ScriptDir

; Initialize global variables
global scrollState := 0 ; 0 = stopped, 1 = scrolling
global scrollDirection := 0 ; 0 = none, 1 = down, -1 = up
global lButtonPressed := false ; Track Left Click state

; Toggle Suspend Hotkeys (e.g., map to F1 or Ditto button)
F1::{
    Suspend
    ToolTip "Hotkeys " (A_IsSuspended ? "Suspended" : "Resumed"), 0, 0
    SetTimer () => ToolTip(), -2000
    return
}

; Block default context menu for XButton1 + RButton
XButton1 & RButton::{
    Send "{Ctrl down}"
    Send "a"
    Send "{Ctrl up}"
    return
}

; XButton1 + Left Click = Enter
XButton1 & LButton::{
    Send "{Enter}"
    return
}

; XButton1 release sends Ctrl + `
XButton1 Up::{
    if (!GetKeyState("LButton", "P") && !GetKeyState("RButton", "P")) {
        Send "{Ctrl down}"
        Send "{``}"
        Send "{Ctrl up}"
    }
    return
}

; MButton release pastes clipboard
MButton Up::{
    Send "{Ctrl down}"
    Send "v"
    Send "{Ctrl up}"
    return
}

; XButton2 + Left Click = Save (Ctrl + S)
XButton2 & LButton::{
    Send "{Ctrl down}"
    Send "s"
    Send "{Ctrl up}"
    return
}

; XButton2 + Right Click = Do nothing
XButton2 & RButton::{
    return
}

; XButton2 release toggles Windows clipboard
XButton2 Up::{
    if (!GetKeyState("LButton", "P") && !GetKeyState("RButton", "P")) {
        Send "#{v}"
    }
    return
}

; Left Click held + Right Click = Copy (Ctrl + C)
RButton::{
    global lButtonPressed
    if (lButtonPressed && !GetKeyState("XButton1", "P") && !GetKeyState("XButton2", "P")) {
        if WinExist("ahk_class #32768") {
            Send "{Esc}"
            Sleep 50
        }
        Send "{Ctrl down}"
        Send "c"
        Send "{Ctrl up}"
        KeyWait "RButton"
        return
    }
    Send "{RButton down}"
    KeyWait "RButton"
    Send "{RButton up}"
    return
}

; Track Left Click state
LButton::{
    global lButtonPressed
    lButtonPressed := true
    Send "{LButton down}"
    return
}

LButton Up::{
    global lButtonPressed
    lButtonPressed := false
    Send "{LButton up}"
    return
}

; --- Keyboard Auto-Scroll Additions ---

; Alt + Page Down for auto-scroll down
!PgDn::{
    global scrollState, scrollDirection
    ToolTip "Alt + PgDn pressed, State: " scrollState, 0, 0
    SetTimer () => ToolTip(), -2000
    if (scrollState = 0) {
        scrollState := 1
        scrollDirection := 1
        SetTimer ScrollDown, 1
    } else {
        scrollState := 0
        scrollDirection := 0
        SetTimer ScrollDown, 0
        SetTimer ScrollUp, 0
    }
    return
}

; Alt + Page Up for auto-scroll up
!PgUp::{
    global scrollState, scrollDirection
    ToolTip "Alt + PgUp pressed, State: " scrollState, 0, 0
    SetTimer () => ToolTip(), -2000
    if (scrollState = 0) {
        scrollState := 1
        scrollDirection := -1
        SetTimer ScrollUp, 1
    } else {
        scrollState := 0
        scrollDirection := 0
        SetTimer ScrollDown, 0
        SetTimer ScrollUp, 0
    }
    return
}

; Page Down or Page Up behavior
PgDn::{
    global scrollState, scrollDirection
    if (scrollState > 0) {
        scrollState := 0
        scrollDirection := 0
        SetTimer ScrollDown, 0
        SetTimer ScrollUp, 0
        ToolTip "Scroll canceled", 0, 20
        SetTimer () => ToolTip(), -2000
    } else {
        Send "{PgDn}"
    }
    return
}

PgUp::{
    global scrollState, scrollDirection
    if (scrollState > 0) {
        scrollState := 0
        scrollDirection := 0
        SetTimer ScrollDown, 0
        SetTimer ScrollUp, 0
        ToolTip "Scroll canceled", 0, 20
        SetTimer () => ToolTip(), -2000
    } else {
        Send "{PgUp}"
    }
    return
}

; Scroll Down function
ScrollDown() {
    global scrollDirection
    if (scrollDirection = 1)
        Send "{WheelDown}"
    return
}

; Scroll Up function
ScrollUp() {
    global scrollDirection
    if (scrollDirection = -1)
        Send "{WheelUp}"
    return
}
