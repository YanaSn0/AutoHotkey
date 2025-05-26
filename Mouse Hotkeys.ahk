#SingleInstance Force  ; Ensures only one instance of the script is running

; Initialize global variables at the top level
lastRButtonTime := 0
doubleClickInterval := 300  ; Kept for reference, not used for select all
rButtonPressTime := 0  ; Track the time of the first RButton press
mButtonPressed := false  ; Track if MButton or scroll was used during LButton or RButton hold
autoScrollActive := false  ; Track if auto-scroll is active
autoScrollDirection := ""  ; "up" or "down"
autoScrollInterval := 130  ; Initial interval in ms (speed 1: 130ms)
scrollCount := 0  ; Count scrolls during LButton or RButton hold
lastWheelDirection := ""  ; Track the last wheel direction
rButtonPressCount := 0  ; Track number of RButton presses while LButton is held
autoScrollMode := 1  ; Default to Mode 1 (auto-scroll stops on key release)

; Use a generic path in the temp directory for the log file
logFile := A_Temp "\MouseHotkeysLog.txt"

; Fail-safe hotkey to exit the script (Ctrl+Shift+Esc)
^+Esc::
{
    MsgBox("Exiting script to prevent lockout.")
    Send("{LButton up}")  ; Ensure LButton is released before exiting
    Send("{Esc}")  ; Close any open context menu
    ExitApp
}

; Helper function to close context menu if open
CloseContextMenu()
{
    if WinExist("ahk_class #32768")  ; Context menu window class
    {
        Send("{Esc}")  ; Send Esc to close the context menu
        Sleep(50)  ; Small delay to ensure it closes
    }
}

; XButton1: Stop auto-scroll and handle Ditto or Down arrow
XButton1::
{
    global autoScrollActive, mButtonPressed
    if (autoScrollActive)  ; Stop auto-scroll on any button press
    {
        autoScrollActive := false
        SetTimer(AutoScroll, 0)  ; Stop the timer
        CloseContextMenu()  ; Close any open context menu
        return
    }
    if GetKeyState("RButton", "P")  ; If RButton is held
    {
        Send("{Down}")  ; Send Down arrow
        mButtonPressed := true  ; Suppress context menu
        return
    }
    Send("^``")  ; Ctrl + ` (backtick) to open Ditto
    return
}

; XButton2: Stop auto-scroll and handle Win+V or Up arrow
XButton2::
{
    global autoScrollActive, mButtonPressed
    if (autoScrollActive)  ; Stop auto-scroll on any button press
    {
        autoScrollActive := false
        SetTimer(AutoScroll, 0)  ; Stop the timer
        CloseContextMenu()  ; Close any open context menu
        return
    }
    if GetKeyState("RButton", "P")  ; If RButton is held
    {
        Send("{Up}")  ; Send Up arrow
        mButtonPressed := true  ; Suppress context menu
        return
    }
    Send("{LWin down}")
    Send("v")
    Send("{LWin up}")
    return
}

; Middle mouse button: Toggle auto-scroll mode or stop auto-scroll and paste
MButton::
{
    global autoScrollActive, autoScrollMode, mButtonPressed
    if (autoScrollActive)  ; Stop auto-scroll on any button press
    {
        autoScrollActive := false
        SetTimer(AutoScroll, 0)  ; Stop the timer
        CloseContextMenu()  ; Close any open context menu
        FileAppend("MButton stopped auto-scroll. Mode: " autoScrollMode "`n", logFile)
        return
    }
    if GetKeyState("RButton", "P")  ; If RButton is held
    {
        ; Toggle between Mode 1 and Mode 2
        if (autoScrollMode = 1)
        {
            autoScrollMode := 2
            FileAppend("Switched to Mode 2: Auto-scroll continues until explicitly stopped.`n", logFile)
        }
        else
        {
            autoScrollMode := 1
            FileAppend("Switched to Mode 1: Auto-scroll stops on key release.`n", logFile)
        }
        mButtonPressed := true  ; Suppress context menu
        return
    }
    Send("^v")  ; Ctrl + V (paste)
    Sleep(50)  ; Small delay to ensure the paste completes properly
    return
}

; WheelUp: Handle auto-scroll when LButton or RButton is held, preserve modifier+Wheel behaviors
*WheelUp::
{
    global autoScrollActive, autoScrollDirection, autoScrollInterval, scrollCount, mButtonPressed, lastWheelDirection
    if (GetKeyState("LButton", "P") || GetKeyState("RButton", "P"))  ; Check if LButton or RButton is held
    {
        mButtonPressed := true  ; Suppress context menu or normal click behavior
        scrollCount += 1

        ; Track wheel direction
        lastWheelDirection := "up"

        if (!autoScrollActive)
        {
            ; Start auto-scroll up (Speed 1: 130ms)
            autoScrollActive := true
            autoScrollDirection := "up"
            autoScrollInterval := 130  ; Speed 1 (ensure it's set)
            scrollCount := 1
            lastWheelDirection := "up"
            SetTimer(AutoScroll, autoScrollInterval)  ; Start timer
        }
        else
        {
            ; Adjust speed based on direction
            if (autoScrollDirection = "up")
            {
                ; Increase speed (decrease interval)
                if (autoScrollInterval = 130)
                    autoScrollInterval := 50  ; Speed 2
                else if (autoScrollInterval = 50)
                    autoScrollInterval := 1  ; Speed 3 (1ms)
                SetTimer(AutoScroll, autoScrollInterval)  ; Update timer with new interval
            }
            else
            {
                ; Stop auto-scroll when scrolling in the opposite direction
                autoScrollActive := false
                SetTimer(AutoScroll, 0)  ; Stop the timer
                Sleep(50)  ; Small delay to ensure timer stops
                return  ; Do not restart in the new direction
            }
        }
        return
    }
    ; Allow normal scrolling if auto-scroll is not active
    if GetKeyState("Ctrl", "P")  ; Check if Ctrl is held
    {
        Send("{Ctrl down}")
        Send("{WheelUp}")  ; Send Ctrl + WheelUp for zooming
        Send("{Ctrl up}")
        return
    }
    else if GetKeyState("Shift", "P")  ; Check if Shift is held
    {
        Send("{Shift down}")
        Send("{WheelUp}")  ; Send Shift + WheelUp for horizontal scrolling
        Send("{Shift up}")
        return
    }
    else if GetKeyState("Alt", "P")  ; Check if Alt is held
    {
        Send("{Alt down}")
        Send("{WheelUp}")  ; Send Alt + WheelUp for app-specific actions
        Send("{Alt up}")
        return
    }
    Send("{WheelUp}")  ; Normal scroll up
    return
}

; WheelDown: Handle auto-scroll when LButton or RButton is held, preserve modifier+Wheel behaviors
*WheelDown::
{
    global autoScrollActive, autoScrollDirection, autoScrollInterval, scrollCount, mButtonPressed, lastWheelDirection
    if (GetKeyState("LButton", "P") || GetKeyState("RButton", "P"))  ; Check if LButton or RButton is held
    {
        mButtonPressed := true  ; Suppress context menu or normal click behavior
        scrollCount += 1

        ; Track wheel direction
        lastWheelDirection := "down"

        if (!autoScrollActive)
        {
            ; Start auto-scroll down (Speed 1: 130ms)
            autoScrollActive := true
            autoScrollDirection := "down"
            autoScrollInterval := 130  ; Speed 1 (ensure it's set)
            scrollCount := 1
            lastWheelDirection := "down"
            SetTimer(AutoScroll, autoScrollInterval)  ; Start timer
        }
        else
        {
            ; Adjust speed based on direction
            if (autoScrollDirection = "down")
            {
                ; Increase speed (decrease interval)
                if (autoScrollInterval = 130)
                    autoScrollInterval := 50  ; Speed 2
                else if (autoScrollInterval = 50)
                    autoScrollInterval := 1  ; Speed 3 (1ms)
                SetTimer(AutoScroll, autoScrollInterval)  ; Update timer with new interval
            }
            else
            {
                ; Stop auto-scroll when scrolling in the opposite direction
                autoScrollActive := false
                SetTimer(AutoScroll, 0)  ; Stop the timer
                Sleep(50)  ; Small delay to ensure timer stops
                return  ; Do not restart in the new direction
            }
        }
        return
    }
    ; Allow normal scrolling if auto-scroll is not active
    if GetKeyState("Ctrl", "P")  ; Check if Ctrl is held
    {
        Send("{Ctrl down}")
        Send("{WheelDown}")  ; Send Ctrl + WheelDown for zooming
        Send("{Ctrl up}")
        return
    }
    else if GetKeyState("Shift", "P")  ; Check if Shift is held
    {
        Send("{Shift down}")
        Send("{WheelDown}")  ; Send Shift + WheelDown for horizontal scrolling
        Send("{Shift up}")
        return
    }
    else if GetKeyState("Alt", "P")  ; Check if Alt is held
    {
        Send("{Alt down}")
        Send("{WheelDown}")  ; Send Alt + WheelDown for app-specific actions
        Send("{Alt up}")
        return
    }
    Send("{WheelDown}")  ; Normal scroll down
    return
}

; Auto-scroll timer function
AutoScroll()
{
    global autoScrollActive, autoScrollDirection
    if (!autoScrollActive)
    {
        SetTimer(AutoScroll, 0)  ; Stop the timer
        return
    }
    ; Send scroll event based on direction
    if (autoScrollDirection = "up")
        Send("{WheelUp}")
    else if (autoScrollDirection = "down")
        Send("{WheelDown}")
    return
}

; Right mouse button press: Handle LButton-held logic and stop auto-scroll
RButton::
{
    global lastRButtonTime, rButtonPressTime, mButtonPressed, scrollCount, rButtonPressCount, autoScrollActive
    if (autoScrollActive)  ; Stop auto-scroll on any button press
    {
        autoScrollActive := false
        SetTimer(AutoScroll, 0)  ; Stop the timer
        mButtonPressed := true  ; Ensure context menu is suppressed on release
        CloseContextMenu()  ; Close any open context menu
        KeyWait("RButton")  ; Wait for RButton to be released to prevent re-trigger
        return
    }
    if GetKeyState("LButton", "P")  ; If LButton is held
    {
        ; Add a small delay to stabilize key detection
        Sleep(10)
        rButtonPressCount += 1  ; Increment press counter
        ; Debug log
        FileAppend("RButton press detected. Count: " rButtonPressCount " Time: " A_TickCount "`n", logFile)
        
        if (rButtonPressCount = 1)
        {
            ; First press: Execute the copy action
            Send("^c")  ; Ctrl + C (copy)
            mButtonPressed := true  ; Suppress context menu
            lastRButtonTime := A_TickCount
            rButtonPressTime := A_TickCount
            KeyWait("RButton")  ; Wait for RButton to be released
            FileAppend("Copy executed. Count: " rButtonPressCount "`n", logFile)
            return
        }
        else if (rButtonPressCount >= 2)
        {
            ; Second press: Execute select all
            Send("^a")  ; Ctrl + A (select all)
            mButtonPressed := true  ; Suppress context menu
            lastRButtonTime := 0  ; Reset the timer
            rButtonPressTime := 0  ; Reset the first press time
            KeyWait("RButton")  ; Wait for RButton to be released
            FileAppend("Select All executed. Count: " rButtonPressCount "`n", logFile)
            return
        }
    }
    ; Reset state at start of RButton press
    mButtonPressed := false
    scrollCount := 0
    KeyWait("RButton")  ; Wait for the physical button to be released
    return
}

; Right mouse button release: Handle context menu and stop auto-scroll in Mode 1
RButton Up::
{
    global mButtonPressed, autoScrollActive, autoScrollMode
    if (autoScrollMode = 1 && autoScrollActive)  ; Stop auto-scroll in Mode 1
    {
        autoScrollActive := false
        SetTimer(AutoScroll, 0)  ; Stop the timer
        FileAppend("RButton released. Auto-scroll stopped in Mode 1.`n", logFile)
    }
    ; Only simulate right-click if no MButton, scroll events, or auto-scroll stop occurred
    if (!mButtonPressed)
    {
        Send("{RButton}")  ; Simulate right-click to open context menu
    }
    CloseContextMenu()  ; Always close any lingering context menu
    mButtonPressed := false  ; Reset state
    return
}

; Left mouse button press: Handle RButton-held logic or stop auto-scroll
LButton::
{
    global autoScrollActive, mButtonPressed, scrollCount, rButtonPressCount
    if (autoScrollActive)  ; Stop auto-scroll on any button press
    {
        autoScrollActive := false
        SetTimer(AutoScroll, 0)  ; Stop the timer
        Send("{LButton up}")  ; Ensure LButton is released
        CloseContextMenu()  ; Force-close any open context menu
        FileAppend("LButton pressed during auto-scroll. Reset rButtonPressCount to 0`n", logFile)
        return
    }
    if GetKeyState("RButton", "P")  ; If RButton is held
    {
        mButtonPressed := true  ; Set flag to suppress context menu
        Send("{Enter}")  ; Send Enter key
        return
    }
    ; Reset state at start of LButton press
    mButtonPressed := false
    scrollCount := 0
    rButtonPressCount := 0  ; Reset RButton press counter
    FileAppend("LButton pressed. Reset rButtonPressCount to 0`n", logFile)
    Send("{LButton down}")  ; Normal left-click down to allow dragging
    return
}

; Left mouse button release: Handle normal click and stop auto-scroll in Mode 1
LButton Up::
{
    global autoScrollActive, mButtonPressed, rButtonPressCount, autoScrollMode
    if (autoScrollMode = 1 && autoScrollActive)  ; Stop auto-scroll in Mode 1
    {
        autoScrollActive := false
        SetTimer(AutoScroll, 0)  ; Stop the timer
        FileAppend("LButton released. Auto-scroll stopped in Mode 1.`n", logFile)
    }
    ; Always send LButton up to ensure release
    Send("{LButton up}")  ; Normal left-click up to complete drag
    rButtonPressCount := 0  ; Reset RButton press counter
    CloseContextMenu()  ; Force-close any open context menu
    FileAppend("LButton released. Reset rButtonPressCount to 0`n", logFile)
    return
}
