#SingleInstance Force  ; Ensures only one instance of the script is running

; Initialize global variables
global lastRButtonTime := 0
global doubleClickInterval := 300  ; Double-click interval in milliseconds
global rButtonPressTime := 0  ; Track the time of the first RButton press
global mButtonPressed := false  ; Track if MButton or scroll was used during RButton hold
global autoScrollActive := false  ; Track if auto-scroll is active
global autoScrollDirection := ""  ; "up" or "down"
global autoScrollInterval := 100  ; Initial interval in ms (speed 1: 100ms)
global scrollCount := 0  ; Count scrolls during RButton hold
global lastWheelDirection := ""  ; Track the last wheel direction

; XButton1: Open Ditto or send Down
XButton1::
{
    global autoScrollActive, mButtonPressed
    if (autoScrollActive)  ; Stop auto-scroll on any button press
    {
        autoScrollActive := false
        SetTimer AutoScroll, 0  ; Stop the timer
        return
    }
    if GetKeyState("RButton", "P")  ; If RButton is held
    {
        Send "{Down}"  ; Send Down arrow
        mButtonPressed := true  ; Suppress context menu
        return
    }
    Send "^``"  ; Ctrl + ` (backtick) to open Ditto
    return
}

; XButton2: Open clipboard history or send Up
XButton2::
{
    global autoScrollActive, mButtonPressed
    if (autoScrollActive)  ; Stop auto-scroll on any button press
    {
        autoScrollActive := false
        SetTimer AutoScroll, 0  ; Stop the timer
        return
    }
    if GetKeyState("RButton", "P")  ; If RButton is held
    {
        Send "{Up}"  ; Send Up arrow
        mButtonPressed := true  ; Suppress context menu
        return
    }
    Send "{LWin down}"  ; Press the Windows key
    Send "v"            ; Press the V key
    Send "{LWin up}"    ; Release the Windows key
    return
}

; Middle mouse button: Paste
MButton::
{
    global autoScrollActive
    if (autoScrollActive)  ; Stop auto-scroll on any button press
    {
        autoScrollActive := false
        SetTimer AutoScroll, 0  ; Stop the timer
        return
    }
    Send "^v"  ; Ctrl + V (paste)
    Sleep 50  ; Small delay to ensure the paste completes properly
    return
}

; WheelUp: Handle auto-scroll when RButton is held, preserve modifier+Wheel behaviors
*WheelUp::
{
    global autoScrollActive, autoScrollDirection, autoScrollInterval, scrollCount, mButtonPressed
    global lastWheelDirection
    if GetKeyState("RButton", "P")  ; Check if RButton is held
    {
        mButtonPressed := true  ; Suppress context menu
        scrollCount += 1

        ; Track wheel direction
        lastWheelDirection := "up"

        if (!autoScrollActive)
        {
            ; Start auto-scroll up (Speed 1: 100ms)
            autoScrollActive := true
            autoScrollDirection := "up"
            autoScrollInterval := 100  ; Speed 1
            scrollCount := 1
            lastWheelDirection := "up"
            SetTimer AutoScroll, autoScrollInterval
        }
        else
        {
            ; Adjust speed based on direction
            if (autoScrollDirection = "up")
            {
                ; Increase speed (decrease interval)
                if (autoScrollInterval = 100)
                    autoScrollInterval := 50  ; Speed 2
                else if (autoScrollInterval = 50)
                    autoScrollInterval := 1   ; Speed 3 (fastest)
            }
            else
            {
                ; Stop immediately when scrolling in the opposite direction
                autoScrollActive := false
                SetTimer AutoScroll, 0  ; Stop the timer
                return
            }
            SetTimer AutoScroll, autoScrollInterval
        }
        return
    }
    ; Allow normal scrolling if auto-scroll is not active
    if GetKeyState("Ctrl", "P")  ; Check if Ctrl is held
    {
        Send "{Ctrl down}"
        Send "{WheelUp}"  ; Send Ctrl + WheelUp for zooming
        Send "{Ctrl up}"
        return
    }
    else if GetKeyState("Shift", "P")  ; Check if Shift is held
    {
        Send "{Shift down}"
        Send "{WheelUp}"  ; Send Shift + WheelUp for horizontal scrolling
        Send "{Shift up}"
        return
    }
    else if GetKeyState("Alt", "P")  ; Check if Alt is held
    {
        Send "{Alt down}"
        Send "{WheelUp}"  ; Send Alt + WheelUp for app-specific actions
        Send "{Alt up}"
        return
    }
    Send "{WheelUp}"  ; Normal scroll up
    return
}

; WheelDown: Handle auto-scroll when RButton is held, preserve modifier+Wheel behaviors
*WheelDown::
{
    global autoScrollActive, autoScrollDirection, autoScrollInterval, scrollCount, mButtonPressed
    global lastWheelDirection
    if GetKeyState("RButton", "P")  ; Check if RButton is held
    {
        mButtonPressed := true  ; Suppress context menu
        scrollCount += 1

        ; Track wheel direction
        lastWheelDirection := "down"

        if (!autoScrollActive)
        {
            ; Start auto-scroll down (Speed 1: 100ms)
            autoScrollActive := true
            autoScrollDirection := "down"
            autoScrollInterval := 100  ; Speed 1
            scrollCount := 1
            lastWheelDirection := "down"
            SetTimer AutoScroll, autoScrollInterval
        }
        else
        {
            ; Adjust speed based on direction
            if (autoScrollDirection = "down")
            {
                ; Increase speed (decrease interval)
                if (autoScrollInterval = 100)
                    autoScrollInterval := 50  ; Speed 2
                else if (autoScrollInterval = 50)
                    autoScrollInterval := 1   ; Speed 3 (fastest)
            }
            else
            {
                ; Stop immediately when scrolling in the opposite direction
                autoScrollActive := false
                SetTimer AutoScroll, 0  ; Stop the timer
                return
            }
            SetTimer AutoScroll, autoScrollInterval
        }
        return
    }
    ; Allow normal scrolling if auto-scroll is not active
    if GetKeyState("Ctrl", "P")  ; Check if Ctrl is held
    {
        Send "{Ctrl down}"
        Send "{WheelDown}"  ; Send Ctrl + WheelDown for zooming
        Send "{Ctrl up}"
        return
    }
    else if GetKeyState("Shift", "P")  ; Check if Shift is held
    {
        Send "{Shift down}"
        Send "{WheelDown}"  ; Send Shift + WheelDown for horizontal scrolling
        Send "{Shift up}"
        return
    }
    else if GetKeyState("Alt", "P")  ; Check if Alt is held
    {
        Send "{Alt down}"
        Send "{WheelDown}"  ; Send Alt + WheelDown for app-specific actions
        Send "{Alt up}"
        return
    }
    Send "{WheelDown}"  ; Normal scroll down
    return
}

; Auto-scroll timer function
AutoScroll()
{
    global autoScrollActive, autoScrollDirection
    if (!autoScrollActive)
    {
        SetTimer AutoScroll, 0  ; Stop the timer
        return
    }
    ; Send scroll event based on direction
    if (autoScrollDirection = "up")
        Send "{WheelUp}"
    else if (autoScrollDirection = "down")
        Send "{WheelDown}"
    return
}

; Right mouse button press: Handle LButton-held logic
RButton::
{
    global lastRButtonTime, doubleClickInterval, rButtonPressTime, mButtonPressed, scrollCount
    if GetKeyState("LButton", "P")  ; If LButton is held
    {
        currentTime := A_TickCount
        if (currentTime - lastRButtonTime <= doubleClickInterval)
        {
            ; Double-click detected
            Send "^a"  ; Ctrl + A (select all)
            mButtonPressed := true  ; Suppress context menu
            lastRButtonTime := 0  ; Reset the timer
            rButtonPressTime := 0  ; Reset the first press time
            KeyWait "RButton"  ; Wait for RButton to be released
            return
        }
        ; First press: Execute the copy action
        Send "^c"  ; Ctrl + C (copy)
        mButtonPressed := true  ; Suppress context menu
        lastRButtonTime := currentTime
        rButtonPressTime := currentTime
        KeyWait "RButton"  ; Wait for RButton to be released
        return
    }
    ; Reset state at start of RButton press
    mButtonPressed := false
    scrollCount := 0
    KeyWait "RButton"  ; Wait for the physical button to be released
    return
}

; Right mouse button release: Handle context menu
RButton up::
{
    global autoScrollActive, mButtonPressed
    if (autoScrollActive)  ; Stop auto-scroll on right-click
    {
        autoScrollActive := false
        SetTimer AutoScroll, 0  ; Stop the timer
        return  ; Suppress context menu
    }
    ; Only simulate right-click if no MButton or scroll events occurred
    if (!mButtonPressed)
    {
        Send "{RButton}"  ; Simulate right-click to open context menu
    }
    return
}

; Left mouse button press: Handle RButton-held logic or stop auto-scroll
LButton::
{
    global autoScrollActive, mButtonPressed
    if (autoScrollActive)  ; Stop auto-scroll on any button press
    {
        autoScrollActive := false
        SetTimer AutoScroll, 0  ; Stop the timer
        return
    }
    if GetKeyState("RButton", "P")  ; If RButton is held
    {
        mButtonPressed := true  ; Set flag to suppress context menu
        Send "{Enter}"  ; Send Enter key
        return
    }
    Send "{LButton down}"  ; Normal left-click down to allow dragging
    return
}

LButton up::
{
    Send "{LButton up}"  ; Normal left-click up to complete drag
    return
}
