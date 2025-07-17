#SingleInstance Force
SetWorkingDir A_ScriptDir

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

; XButton1 release sends Ctrl + ` only if no other buttons are pressed
XButton1 Up::{
    if (!GetKeyState("LButton", "P") && !GetKeyState("RButton", "P")) {
        Send "{Ctrl down}"
        Send "{``}"
        Send "{Ctrl up}"
    }
    return
}

; MButton release pastes clipboard (no checks)
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

; XButton2 + Right Click = Copy (Ctrl + C)
XButton2 & RButton::{
    Send "{Ctrl down}"
    Send "c"
    Send "{Ctrl up}"
    return
}

; XButton2 release toggles Windows clipboard, only if Left or Right were not pressed
XButton2 Up::{
    if (!GetKeyState("LButton", "P") && !GetKeyState("RButton", "P")) {
        Send "#{v}"
    }
    return
}

; --- Keyboard Auto-Scroll Additions ---

; Initialize global variables
global scrollState := 0 ; 0 = stopped, 1 = 400 ms, 2 = 1 ms
global scrollDirection := 0 ; 0 = none, 1 = down, -1 = up

; Alt + Page Down for auto-scroll down
!PgDn::{
    global scrollState, scrollDirection
    ToolTip "Alt + PgDn pressed, State: " scrollState, 0, 0 ; Debug
    SetTimer () => ToolTip(), -2000
    if (scrollState = 0)
    {
        scrollState := 1
        scrollDirection := 1
        SetTimer ScrollDown, 400
    }
    else if (scrollState = 1)
    {
        scrollState := 2
        SetTimer ScrollDown, 1
    }
    else if (scrollState = 2)
    {
        scrollState := 0
        scrollDirection := 0
        SetTimer ScrollDown, 0
    }
    return
}

; Alt + Page Up for auto-scroll up
!PgUp::{
    global scrollState, scrollDirection
    ToolTip "Alt + PgUp pressed, State: " scrollState, 0, 0 ; Debug
    SetTimer () => ToolTip(), -2000
    if (scrollState = 0)
    {
        scrollState := 1
        scrollDirection := -1
        SetTimer ScrollUp, 400
    }
    else if (scrollState = 1)
    {
        scrollState := 2
        SetTimer ScrollUp, 1
    }
    else if (scrollState = 2)
    {
        scrollState := 0
        scrollDirection := 0
        SetTimer ScrollUp, 0
    }
    return
}

; Page Down or Page Up to cancel auto-scroll
PgDn::
PgUp::{
    global scrollState, scrollDirection
    if (scrollState > 0)
    {
        scrollState := 0
        scrollDirection := 0
        SetTimer ScrollDown, 0
        SetTimer ScrollUp, 0
        ToolTip "Scroll canceled", 0, 20 ; Debug
        SetTimer () => ToolTip(), -2000
    }
    return
}

; Scroll Down function
ScrollDown()
{
    global scrollDirection
    if (scrollDirection = 1)
        Send "{WheelDown}"
    return
}

; Scroll Up function
ScrollUp()
{
    global scrollDirection
    if (scrollDirection = -1)
        Send "{WheelUp}"
    return
}
