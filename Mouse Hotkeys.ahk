#SingleInstance Force  ; Ensures only one instance of the script is running

; Initialize global variables
global lastRButtonTime := 0
global doubleClickInterval := 300  ; Double-click interval in milliseconds
global rButtonPressTime := 0  ; Track the time of the first RButton press
global lButtonHeld := false  ; Track if LButton is held
global mButtonPressed := false  ; Track if MButton or scroll was used during RButton hold
global autoScrollActive := false  ; Track if auto-scroll is active
global autoScrollDirection := ""  ; "up" or "down"
global autoScrollInterval := 100  ; Initial interval in ms (speed 1)
global scrollCount := 0  ; Count scrolls during RButton hold

; XButton1: Open Ditto
XButton1::
{
    Send "^``"  ; Ctrl + ` (backtick) to open Ditto
    return
}

; XButton2: Open clipboard history
XButton2::
{
    Send "{LWin down}"  ; Press the Windows key
    Send "v"            ; Press the V key
    Send "{LWin up}"    ; Release the Windows key
    return
}

; Middle mouse button: Paste or Enter if RButton is held
MButton::
{
    global mButtonPressed
    if GetKeyState("RButton", "P")  ; Check if RButton is physically held
    {
        Send "{Enter}"  ; Send Enter key
        mButtonPressed := true  ; Mark that MButton was pressed
    }
    else
    {
        Send "^v"  ; Ctrl + V (paste)
        Sleep 50  ; Small delay to ensure the paste completes properly
    }
    return
}

; WheelUp: Handle auto-scroll when RButton is held
*WheelUp::
{
    global autoScrollActive, autoScrollDirection, autoScrollInterval, scrollCount, mButtonPressed
    if GetKeyState("RButton", "P")  ; Check if RButton is held
    {
        mButtonPressed := true  ; Suppress context menu
        scrollCount += 1
        if !autoScrollActive
        {
            ; Start auto-scroll up (Speed 1: 100ms, 10 scrolls/sec)
            autoScrollActive := true
            autoScrollDirection := "up"
            autoScrollInterval := 100  ; Speed 1
            scrollCount := 1
            SetTimer AutoScroll, autoScrollInterval
        }
        else if scrollCount = 2
        {
            ; Second scroll: Speed 2 (50ms, 20 scrolls/sec)
            autoScrollInterval := 50
            SetTimer AutoScroll, autoScrollInterval
        }
        else if scrollCount = 3
        {
            ; Third scroll: Speed 3 (25ms, 40 scrolls/sec)
            autoScrollInterval := 25
            SetTimer AutoScroll, autoScrollInterval
        }
    }
    else
    {
        Send "{WheelUp}"  ; Normal scroll up
    }
    return
}

; WheelDown: Handle auto-scroll when RButton is held
*WheelDown::
{
    global autoScrollActive, autoScrollDirection, autoScrollInterval, scrollCount, mButtonPressed
    if GetKeyState("RButton", "P")  ; Check if RButton is held
    {
        mButtonPressed := true  ; Suppress context menu
        scrollCount += 1
        if !autoScrollActive
        {
            ; Start auto-scroll down (Speed 1: 100ms, 10 scrolls/sec)
            autoScrollActive := true
            autoScrollDirection := "down"
            autoScrollInterval := 100  ; Speed 1
            scrollCount := 1
            SetTimer AutoScroll, autoScrollInterval
        }
        else if scrollCount = 2
        {
            ; Second scroll: Speed 2 (50ms, 20 scrolls/sec)
            autoScrollInterval := 50
            SetTimer AutoScroll, autoScrollInterval
        }
        else if scrollCount = 3
        {
            ; Third scroll: Speed 3 (25ms, 40 scrolls/sec)
            autoScrollInterval := 25
            SetTimer AutoScroll, autoScrollInterval
        }
    }
    else
    {
        Send "{WheelDown}"  ; Normal scroll down
    }
    return
}

; Auto-scroll timer function
AutoScroll()
{
    global autoScrollActive, autoScrollDirection
    if !autoScrollActive || !GetKeyState("RButton", "P")
    {
        ; Stop auto-scroll
        autoScrollActive := false
        SetTimer AutoScroll, 0  ; Stop the timer
        return
    }
    ; Send scroll event based on direction
    if autoScrollDirection = "up"
        Send "{WheelUp}"
    else if autoScrollDirection = "down"
        Send "{WheelDown}"
    return
}

; Right mouse button press: Handle LButton-held logic
RButton::
{
    global lastRButtonTime, doubleClickInterval, rButtonPressTime, lButtonHeld, mButtonPressed
    global autoScrollActive, scrollCount

    ; Check if LButton is held at the start of the RButton press
    lButtonHeld := GetKeyState("LButton", "P")

    if lButtonHeld
    {
        currentTime := A_TickCount
        if currentTime - lastRButtonTime <= doubleClickInterval
        {
            ; Double-click detected
            Send "^a"  ; Ctrl + A (select all)
            lastRButtonTime := 0  ; Reset the timer
            rButtonPressTime := 0  ; Reset the first press time
            KeyWait "RButton"  ; Wait for RButton to be released
        }
        else
        {
            ; First press: Execute the copy action
            Send "^c"  ; Ctrl + C (copy)
            lastRButtonTime := currentTime
            rButtonPressTime := currentTime
            KeyWait "RButton"  ; Wait for RButton to be released
        }
    }
    else
    {
        ; Reset state at start of RButton press
        mButtonPressed := false
        scrollCount := 0
        KeyWait "RButton"  ; Wait for the physical button to be released
    }
    return
}

; Right mouse button release: Handle context menu and stop auto-scroll
RButton up::
{
    global autoScrollActive, mButtonPressed
    ; Stop auto-scroll if active
    if autoScrollActive
    {
        autoScrollActive := false
        SetTimer AutoScroll, 0  ; Stop the timer
    }
    ; Only simulate right-click if no MButton or scroll events occurred
    if !mButtonPressed
    {
        Send "{RButton}"  ; Simulate right-click to open context menu
    }
    return
}
