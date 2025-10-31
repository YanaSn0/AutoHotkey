#SingleInstance Force
SetWorkingDir A_ScriptDir

; --- Global state ---
global scrollState := 0        ; 0 = stopped, 1 = scrolling
global scrollDirection := 0    ; 0 = none, 1 = down, -1 = up
global lButtonPressed := false ; Track Left Click state

; --- Toggle suspend (F1) ---
F1:: {
    Suspend()
    ToolTip("Hotkeys " (A_IsSuspended ? "Suspended" : "Resumed"), 0, 0)
    SetTimer(() => ToolTip(), -2000)
}

; --- XButton1 combos ---
XButton1 & RButton:: {
    Send("^a") ; Select all
}
XButton1 & LButton:: {
    Send("{Enter}")
}
XButton1 Up:: {
    if (!GetKeyState("LButton","P") && !GetKeyState("RButton","P"))
        Send("^{``}")
}

; --- MButton ---
MButton Up:: {
    Send("^v")
}

; --- XButton2 combos ---
XButton2 & LButton:: {
    Send("^s")
}
XButton2 & RButton:: {
    ; Do nothing
}
XButton2 Up:: {
    if (!GetKeyState("LButton","P") && !GetKeyState("RButton","P"))
        Send("#{v}")
}

; --- Left Button tracking ---
~LButton:: {
    global lButtonPressed := true
}
~LButton Up:: {
    global lButtonPressed := false
}

; --- Right Button logic ---
~RButton:: {
    global lButtonPressed
    if (lButtonPressed && !GetKeyState("XButton1","P") && !GetKeyState("XButton2","P")) {
        if WinExist("ahk_class #32768") {
            Send("{Esc}")
            Sleep(50)
        }
        Send("^c")
        KeyWait("RButton")
        return
    }
}

; --- Auto-scroll (Alt+PgDn / Alt+PgUp) ---
!PgDn:: {
    global scrollState, scrollDirection
    if (scrollState = 0) {
        scrollState := 1, scrollDirection := 1
        SetTimer(ScrollDown, 1)
    } else {
        scrollState := 0, scrollDirection := 0
        SetTimer(ScrollDown, 0)
        SetTimer(ScrollUp, 0)
    }
    ToolTip("Alt+PgDn pressed, State: " scrollState, 0, 0)
    SetTimer(() => ToolTip(), -2000)
}

!PgUp:: {
    global scrollState, scrollDirection
    if (scrollState = 0) {
        scrollState := 1, scrollDirection := -1
        SetTimer(ScrollUp, 1)
    } else {
        scrollState := 0, scrollDirection := 0
        SetTimer(ScrollDown, 0)
        SetTimer(ScrollUp, 0)
    }
    ToolTip("Alt+PgUp pressed, State: " scrollState, 0, 0)
    SetTimer(() => ToolTip(), -2000)
}

PgDn:: {
    global scrollState, scrollDirection
    if (scrollState > 0) {
        scrollState := 0, scrollDirection := 0
        SetTimer(ScrollDown, 0)
        SetTimer(ScrollUp, 0)
        ToolTip("Scroll canceled", 0, 20)
        SetTimer(() => ToolTip(), -2000)
    } else Send("{PgDn}")
}

PgUp:: {
    global scrollState, scrollDirection
    if (scrollState > 0) {
        scrollState := 0, scrollDirection := 0
        SetTimer(ScrollDown, 0)
        SetTimer(ScrollUp, 0)
        ToolTip("Scroll canceled", 0, 20)
        SetTimer(() => ToolTip(), -2000)
    } else Send("{PgUp}")
}

; --- Scroll functions ---
ScrollDown() {
    global scrollDirection
    if (scrollDirection = 1)
        Send("{WheelDown}")
}
ScrollUp() {
    global scrollDirection
    if (scrollDirection = -1)
        Send("{WheelUp}")
}
