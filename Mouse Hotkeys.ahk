#SingleInstance Force

; Initialize global variables
lastRButtonTime := 0
doubleClickInterval := 300
rButtonPressTime := 0
mButtonPressed := false
autoScrollActive := false
scrollSpeed := 0 ; Speed from -5 (fastest down) to 5 (fastest up), 0 is stopped
scrollCount := 0
oppositeScrollCount := 0 ; Track opposite scroll events
lastWheelDirection := ""
rButtonPressCount := 0
autoScrollMode := 1
selectAllTriggered := false
copyTriggered := false
undoTriggered := false
saveTriggered := false
recentAutoScroll := false
xButton1OtherButtons := false ; Track if other buttons used with XButton1
xButton2OtherButtons := false ; Track if other buttons used with XButton2
rButtonOtherButtons := false ; Track if other buttons used with RButton
lastContextMenuCloseTime := 0
lastSpeedChangeTime := 0
lastAutoScrollTime := 0
lastSaveTime := 0 ; Track last save

logFile := A_Temp "\MouseHotkeysLog.txt"

^+Esc::
{
    MsgBox "Exiting script to prevent lockout."
    Send("{LButton up}")
    Send("{Esc}")
    ExitApp
}

CloseClipboardInterfaces()
{
    global lastContextMenuCloseTime
    closed := false
    ; Close Ditto (default class, adjust if custom)
    if WinExist("ahk_class ThunderRT6FormDC ahk_exe Ditto.exe")
    {
        Send("{Esc}")
        Sleep(50)
        closed := true
    }
    ; Close context menu
    if WinExist("ahk_class #32768")
    {
        Send("{Esc}")
        Sleep(50)
        closed := true
    }
    if (closed)
    {
        lastContextMenuCloseTime := A_TickCount
        FileAppend("Closed Ditto/context menu at " A_TickCount ".\n", logFile)
        return true
    }
    return false
}

XButton1::
{
    global mButtonPressed, selectAllTriggered, copyTriggered, recentAutoScroll, lastAutoScrollTime, xButton1OtherButtons, autoScrollActive, scrollSpeed
    if (autoScrollActive)
    {
        autoScrollActive := false
        scrollSpeed := 0
        SetTimer(AutoScroll, 0)
        mButtonPressed := true
        recentAutoScroll := true
        lastAutoScrollTime := A_TickCount
        CloseClipboardInterfaces()
        FileAppend("XButton1 pressed: Auto-scroll stopped. autoScrollActive=" autoScrollActive ", scrollSpeed=" scrollSpeed ".\n", logFile)
        return
    }
    mButtonPressed := true
    selectAllTriggered := false
    copyTriggered := false
    xButton1OtherButtons := false
    autoScrollActive := false
    scrollSpeed := 0
    FileAppend("XButton1 pressed: mButtonPressed=" mButtonPressed ", autoScrollActive=" autoScrollActive ", xButton1OtherButtons=" xButton1OtherButtons ".\n", logFile)
    return
}

XButton1 Up::
{
    global mButtonPressed, selectAllTriggered, copyTriggered, recentAutoScroll, lastAutoScrollTime, xButton1OtherButtons, autoScrollActive
    if GetKeyState("RButton", "P")
    {
        Send("{Down}")
        mButtonPressed := true
        FileAppend("XButton1 released: Sent Down with RButton held.\n", logFile)
        CloseClipboardInterfaces()
        return
    }
    currentTime := A_TickCount
    if (!selectAllTriggered && !copyTriggered && !recentAutoScroll && !xButton1OtherButtons && (currentTime - lastAutoScrollTime > 1000))
    {
        Send("^``")
        FileAppend("XButton1 released: Sent Ctrl+` (Ditto).\n", logFile)
        CloseClipboardInterfaces()
    }
    else
    {
        FileAppend("XButton1 released: Skipped Ditto due to " (selectAllTriggered ? "select all" : copyTriggered ? "copy" : xButton1OtherButtons ? "other buttons" : "recent auto-scroll") ", autoScrollTime=" (currentTime - lastAutoScrollTime) ".\n", logFile)
        CloseClipboardInterfaces()
    }
    mButtonPressed := false
    selectAllTriggered := false
    copyTriggered := false
    xButton1OtherButtons := false
    recentAutoScroll := false
    if (autoScrollActive && autoScrollMode = 1)
    {
        autoScrollActive := false
        scrollSpeed := 0
        SetTimer(AutoScroll, 0)
        FileAppend("XButton1 released: Auto-scroll stopped in Mode 1.\n", logFile)
    }
    FileAppend("XButton1 Up: mButtonPressed=" mButtonPressed ", autoScrollActive=" autoScrollActive ".\n", logFile)
    return
}

XButton2::
{
    global autoScrollActive, mButtonPressed, undoTriggered, saveTriggered, recentAutoScroll, lastAutoScrollTime, xButton2OtherButtons
    if (autoScrollActive)
    {
        autoScrollActive := false
        scrollSpeed := 0
        SetTimer(AutoScroll, 0)
        mButtonPressed := true
        recentAutoScroll := true
        lastAutoScrollTime := A_TickCount
        CloseClipboardInterfaces()
        FileAppend("XButton2 pressed: Auto-scroll stopped.\n", logFile)
        return
    }
    mButtonPressed := true
    undoTriggered := false
    saveTriggered := false
    xButton2OtherButtons := false
    FileAppend("XButton2 pressed: mButtonPressed=" mButtonPressed ", saveTriggered=" saveTriggered ", xButton2OtherButtons=" xButton2OtherButtons ".\n", logFile)
    return
}

XButton2 Up::
{
    global mButtonPressed, undoTriggered, saveTriggered, lastSaveTime, xButton2OtherButtons, autoScrollActive
    if GetKeyState("RButton", "P")
    {
        Send("{Up}")
        mButtonPressed := true
        FileAppend("XButton2 released: Sent Up with RButton held.\n", logFile)
        CloseClipboardInterfaces()
        return
    }
    currentTime := A_TickCount
    if (!undoTriggered && !saveTriggered && !xButton2OtherButtons && (currentTime - lastSaveTime > 1000))
    {
        Send("{LWin down}")
        Send("v")
        Send("{LWin up}")
        FileAppend("XButton2 released: Sent Win+V at " currentTime ".\n", logFile)
        CloseClipboardInterfaces()
    }
    else
    {
        FileAppend("XButton2 released: Skipped Win+V due to undoTriggered=" undoTriggered ", saveTriggered=" saveTriggered ", xButton2OtherButtons=" xButton2OtherButtons ", lastSaveTime=" lastSaveTime ".\n", logFile)
        CloseClipboardInterfaces()
    }
    mButtonPressed := false
    undoTriggered := false
    saveTriggered := false
    xButton2OtherButtons := false
    if (autoScrollActive && autoScrollMode = 1)
    {
        autoScrollActive := false
        scrollSpeed := 0
        SetTimer(AutoScroll, 0)
        FileAppend("XButton2 released: Auto-scroll stopped in Mode 1.\n", logFile)
    }
    FileAppend("XButton2 Up: mButtonPressed=" mButtonPressed ", saveTriggered=" saveTriggered ".\n", logFile)
    return
}

MButton::
{
    global autoScrollActive, autoScrollMode, mButtonPressed, recentAutoScroll, lastAutoScrollTime, xButton1OtherButtons, xButton2OtherButtons, rButtonOtherButtons
    if (autoScrollActive)
    {
        autoScrollActive := false
        scrollSpeed := 0
        SetTimer(AutoScroll, 0)
        mButtonPressed := true
        recentAutoScroll := true
        lastAutoScrollTime := A_TickCount
        CloseClipboardInterfaces()
        FileAppend("MButton stopped auto-scroll. Mode: " autoScrollMode "\n", logFile)
        return
    }
    if GetKeyState("RButton", "P")
    {
        if (autoScrollMode = 1)
        {
            autoScrollMode := 2
            FileAppend("Switched to Mode 2: Auto-scroll continues until explicitly stopped.\n", logFile)
        }
        else
        {
            autoScrollMode := 1
            FileAppend("Switched to Mode 1: Auto-scroll stops on key release.\n", logFile)
        }
        mButtonPressed := true
        xButton1OtherButtons := true
        xButton2OtherButtons := true
        CloseClipboardInterfaces()
        return
    }
    if GetKeyState("XButton1", "P")
        xButton1OtherButtons := true
    if GetKeyState("XButton2", "P")
        xButton2OtherButtons := true
    if GetKeyState("LButton", "P")
        rButtonOtherButtons := true
    Send("^v")
    Sleep(50)
    CloseClipboardInterfaces()
    FileAppend("MButton pressed: Sent Ctrl+V.\n", logFile)
    return
}

*WheelUp::
{
    global autoScrollActive, scrollSpeed, scrollCount, oppositeScrollCount, mButtonPressed, lastWheelDirection, autoScrollMode, recentAutoScroll, lastSpeedChangeTime, lastAutoScrollTime, xButton1OtherButtons, xButton2OtherButtons, rButtonOtherButtons
    currentTime := A_TickCount
    if GetKeyState("XButton1", "P")
        xButton1OtherButtons := true
    if GetKeyState("XButton2", "P")
        xButton2OtherButtons := true
    if GetKeyState("RButton", "P")
        rButtonOtherButtons := true
    if GetKeyState("LButton", "P")
        rButtonOtherButtons := true
    if (autoScrollActive && autoScrollMode = 2 && !GetKeyState("LButton", "P") && !GetKeyState("RButton", "P") && !GetKeyState("XButton1", "P") && !GetKeyState("XButton2", "P"))
    {
        if (scrollSpeed >= 0)
        {
            if (currentTime - lastSpeedChangeTime > 100 && scrollSpeed < 5)
            {
                scrollSpeed += 1
                SetTimer(AutoScroll, GetScrollInterval(scrollSpeed))
                lastSpeedChangeTime := currentTime
                lastAutoScrollTime := currentTime
                FileAppend("WheelUp: Auto-scroll speed increased in Mode 2 (no buttons): Speed " scrollSpeed " (up) at " currentTime ".\n", logFile)
            }
        }
        else
        {
            if (currentTime - lastSpeedChangeTime > 100)
            {
                oppositeScrollCount += 1
                scrollSpeed += 1
                if (scrollSpeed = 0)
                {
                    autoScrollActive := false
                    SetTimer(AutoScroll, 0)
                    FileAppend("WheelUp: Auto-scroll stopped in Mode 2 (speed 0) at " currentTime ".\n", logFile)
                }
                else
                {
                    SetTimer(AutoScroll, GetScrollInterval(scrollSpeed))
                    lastSpeedChangeTime := currentTime
                    lastAutoScrollTime := currentTime
                    FileAppend("WheelUp: Auto-scroll speed decreased in Mode 2 (no buttons): Speed " scrollSpeed " (up), Opposite count " oppositeScrollCount " at " currentTime ".\n", logFile)
                }
            }
        }
        CloseClipboardInterfaces()
        return
    }
    if (GetKeyState("LButton", "P") || GetKeyState("RButton", "P") || GetKeyState("XButton1", "P") || GetKeyState("XButton2", "P"))
    {
        mButtonPressed := true
        scrollCount += 1
        lastWheelDirection := "up"
        if (!autoScrollActive)
        {
            CloseClipboardInterfaces()
            autoScrollActive := true
            scrollSpeed := 1
            scrollCount := 1
            oppositeScrollCount := 0
            lastSpeedChangeTime := currentTime
            lastAutoScrollTime := currentTime
            SetTimer(AutoScroll, GetScrollInterval(scrollSpeed))
            FileAppend("WheelUp: Auto-scroll started: Speed " scrollSpeed " (up) at " currentTime ", xButton1OtherButtons=" xButton1OtherButtons ", xButton2OtherButtons=" xButton2OtherButtons ".\n", logFile)
        }
        else
        {
            if (scrollSpeed >= 0)
            {
                if (currentTime - lastSpeedChangeTime > 100 && scrollSpeed < 5)
                {
                    scrollSpeed += 1
                    SetTimer(AutoScroll, GetScrollInterval(scrollSpeed))
                    lastSpeedChangeTime := currentTime
                    lastAutoScrollTime := currentTime
                    FileAppend("WheelUp: Auto-scroll speed increased: Speed " scrollSpeed " (up) at " currentTime ".\n", logFile)
                }
            }
            else
            {
                if (currentTime - lastSpeedChangeTime > 100)
                {
                    oppositeScrollCount += 1
                    scrollSpeed += 1
                    if (scrollSpeed = 0)
                    {
                        autoScrollActive := false
                        SetTimer(AutoScroll, 0)
                        FileAppend("WheelUp: Auto-scroll stopped: Speed 0 at " currentTime ".\n", logFile)
                    }
                    else
                    {
                        SetTimer(AutoScroll, GetScrollInterval(scrollSpeed))
                        lastSpeedChangeTime := currentTime
                        lastAutoScrollTime := currentTime
                        FileAppend("WheelUp: Auto-scroll speed decreased: Speed " scrollSpeed " (up), Opposite count " oppositeScrollCount " at " currentTime ".\n", logFile)
                    }
                }
            }
        }
        CloseClipboardInterfaces()
        return
    }
    if GetKeyState("Ctrl", "P")
    {
        Send("{Ctrl down}")
        Send("{WheelUp}")
        Send("{Ctrl up}")
        return
    }
    else if GetKeyState("Shift", "P")
    {
        Send("{Shift down}")
        Send("{WheelUp}")
        Send("{Shift up}")
        return
    }
    else if GetKeyState("Alt", "P")
    {
        Send("{Alt down}")
        Send("{WheelUp}")
        Send("{Alt up}")
        return
    }
    Send("{WheelUp}")
    return
}

*WheelDown::
{
    global autoScrollActive, scrollSpeed, scrollCount, oppositeScrollCount, mButtonPressed, lastWheelDirection, autoScrollMode, recentAutoScroll, lastSpeedChangeTime, lastAutoScrollTime, xButton1OtherButtons, xButton2OtherButtons, rButtonOtherButtons
    currentTime := A_TickCount
    if GetKeyState("XButton1", "P")
        xButton1OtherButtons := true
    if GetKeyState("XButton2", "P")
        xButton2OtherButtons := true
    if GetKeyState("RButton", "P")
        rButtonOtherButtons := true
    if GetKeyState("LButton", "P")
        rButtonOtherButtons := true
    if (autoScrollActive && autoScrollMode = 2 && !GetKeyState("LButton", "P") && !GetKeyState("RButton", "P") && !GetKeyState("XButton1", "P") && !GetKeyState("XButton2", "P"))
    {
        if (scrollSpeed <= 0)
        {
            if (currentTime - lastSpeedChangeTime > 100 && scrollSpeed > -5)
            {
                scrollSpeed -= 1
                SetTimer(AutoScroll, GetScrollInterval(scrollSpeed))
                lastSpeedChangeTime := currentTime
                lastAutoScrollTime := currentTime
                FileAppend("WheelDown: Auto-scroll speed increased in Mode 2 (no buttons): Speed " scrollSpeed " (down) at " currentTime ".\n", logFile)
            }
        }
        else
        {
            if (currentTime - lastSpeedChangeTime > 100)
            {
                oppositeScrollCount += 1
                scrollSpeed -= 1
                if (scrollSpeed = 0)
                {
                    autoScrollActive := false
                    SetTimer(AutoScroll, 0)
                    FileAppend("WheelDown: Auto-scroll stopped in Mode 2 (speed 0) at " currentTime ".\n", logFile)
                }
                else
                {
                    SetTimer(AutoScroll, GetScrollInterval(scrollSpeed))
                    lastSpeedChangeTime := currentTime
                    lastAutoScrollTime := currentTime
                    FileAppend("WheelDown: Auto-scroll speed decreased in Mode 2 (no buttons): Speed " scrollSpeed " (down), Opposite count " oppositeScrollCount " at " currentTime ".\n", logFile)
                }
            }
        }
        CloseClipboardInterfaces()
        return
    }
    if (GetKeyState("LButton", "P") || GetKeyState("RButton", "P") || GetKeyState("XButton1", "P") || GetKeyState("XButton2", "P"))
    {
        mButtonPressed := true
        scrollCount += 1
        lastWheelDirection := "down"
        if (!autoScrollActive)
        {
            CloseClipboardInterfaces()
            autoScrollActive := true
            scrollSpeed := -1
            scrollCount := 1
            oppositeScrollCount := 0
            lastSpeedChangeTime := currentTime
            lastAutoScrollTime := currentTime
            SetTimer(AutoScroll, GetScrollInterval(scrollSpeed))
            FileAppend("WheelDown: Auto-scroll started: Speed " scrollSpeed " (down) at " currentTime ", xButton1OtherButtons=" xButton1OtherButtons ", xButton2OtherButtons=" xButton2OtherButtons ".\n", logFile)
        }
        else
        {
            if (scrollSpeed <= 0)
            {
                if (currentTime - lastSpeedChangeTime > 100 && scrollSpeed > -5)
                {
                    scrollSpeed -= 1
                    SetTimer(AutoScroll, GetScrollInterval(scrollSpeed))
                    lastSpeedChangeTime := currentTime
                    lastAutoScrollTime := currentTime
                    FileAppend("WheelDown: Auto-scroll speed increased: Speed " scrollSpeed " (down) at " currentTime ".\n", logFile)
                }
            }
            else
            {
                if (currentTime - lastSpeedChangeTime > 100)
                {
                    oppositeScrollCount += 1
                    scrollSpeed -= 1
                    if (scrollSpeed = 0)
                    {
                        autoScrollActive := false
                        SetTimer(AutoScroll, 0)
                        FileAppend("WheelDown: Auto-scroll stopped: Speed 0 at " currentTime ".\n", logFile)
                    }
                    else
                    {
                        SetTimer(AutoScroll, GetScrollInterval(scrollSpeed))
                        lastSpeedChangeTime := currentTime
                        lastAutoScrollTime := currentTime
                        FileAppend("WheelDown: Auto-scroll speed decreased: Speed " scrollSpeed " (down), Opposite count " oppositeScrollCount " at " currentTime ".\n", logFile)
                    }
                }
            }
        }
        CloseClipboardInterfaces()
        return
    }
    if GetKeyState("Ctrl", "P")
    {
        Send("{Ctrl down}")
        Send("{WheelDown}")
        Send("{Ctrl up}")
        return
    }
    else if GetKeyState("Shift", "P")
    {
        Send("{Shift down}")
        Send("{WheelDown}")
        Send("{Shift up}")
        return
    }
    else if GetKeyState("Alt", "P")
    {
        Send("{Alt down}")
        Send("{WheelDown}")
        Send("{Alt up}")
        return
    }
    Send("{WheelDown}")
    return
}

GetScrollInterval(speed)
{
    if (speed = 0)
        return 0
    else if (speed = 5 || speed = -5)
        return 1
    else if (speed = 4 || speed = -4)
        return 25
    else if (speed = 3 || speed = -3)
        return 50
    else if (speed = 2 || speed = -2)
        return 100
    else if (speed = 1 || speed = -1)
        return 150
    return 150
}

AutoScroll()
{
    global autoScrollActive, scrollSpeed, lastAutoScrollTime
    if (!autoScrollActive || scrollSpeed = 0)
    {
        SetTimer(AutoScroll, 0)
        autoScrollActive := false
        return
    }
    if (scrollSpeed > 0)
        Send("{WheelUp}")
    else if (scrollSpeed < 0)
        Send("{WheelDown}")
    lastAutoScrollTime := A_TickCount
    return
}

RButton::
{
    global lastRButtonTime, mButtonPressed, scrollCount, autoScrollActive, selectAllTriggered, undoTriggered, saveTriggered, recentAutoScroll, lastAutoScrollTime, lastSaveTime, copyTriggered, xButton1OtherButtons, xButton2OtherButtons
    if (autoScrollActive)
    {
        autoScrollActive := false
        scrollSpeed := 0
        SetTimer(AutoScroll, 0)
        mButtonPressed := false
        recentAutoScroll := true
        lastAutoScrollTime := A_TickCount
        CloseClipboardInterfaces()
        KeyWait("RButton")
        FileAppend("RButton pressed: Auto-scroll stopped.\n", logFile)
        return
    }
    if GetKeyState("LButton", "P")
    {
        copyTriggered := true
        mButtonPressed := true
        Send("^c")
        xButton1OtherButtons := true
        xButton2OtherButtons := true
        FileAppend("RButton pressed with LButton held: Sent Ctrl+C (copy), mButtonPressed=" mButtonPressed ", copyTriggered=" copyTriggered ".\n", logFile)
        KeyWait("RButton")
        KeyWait("LButton", "T0.5")
        CloseClipboardInterfaces()
        mButtonPressed := false
        copyTriggered := false
        return
    }
    if GetKeyState("XButton1", "P")
    {
        Send("^a")
        mButtonPressed := true
        selectAllTriggered := true
        xButton2OtherButtons := true
        FileAppend("RButton pressed with XButton1 held: Sent Ctrl+A (select all).\n", logFile)
        KeyWait("RButton")
        CloseClipboardInterfaces()
        return
    }
    if GetKeyState("XButton2", "P")
    {
        currentTime := A_TickCount
        if (currentTime - lastRButtonTime > 200)
        {
            Send("^z")
            mButtonPressed := true
            undoTriggered := true
            lastRButtonTime := currentTime
            xButton1OtherButtons := true
            FileAppend("RButton pressed with XButton2 held: Sent Ctrl+Z (undo). Time: " currentTime ".\n", logFile)
        }
        else
        {
            FileAppend("RButton pressed with XButton2 held: Undo skipped due to debounce. Time: " currentTime ".\n", logFile)
        }
        KeyWait("RButton")
        CloseClipboardInterfaces()
        return
    }
    if GetKeyState("MButton", "P")
        xButton1OtherButtons := true
        xButton2OtherButtons := true
    mButtonPressed := false
    scrollCount := 0
    FileAppend("RButton pressed: mButtonPressed=" mButtonPressed ".\n", logFile)
    KeyWait("RButton")
    return
}

RButton Up::
{
    global mButtonPressed, autoScrollActive, autoScrollMode, recentAutoScroll, lastContextMenuCloseTime, lastAutoScrollTime, lastSaveTime, rButtonOtherButtons
    if (autoScrollMode = 1 && autoScrollActive)
    {
        autoScrollActive := false
        scrollSpeed := 0
        SetTimer(AutoScroll, 0)
        mButtonPressed := true
        recentAutoScroll := true
        lastAutoScrollTime := A_TickCount
        CloseClipboardInterfaces()
        FileAppend("RButton released: Auto-scroll stopped in Mode 1.\n", logFile)
    }
    currentTime := A_TickCount
    if (!mButtonPressed && !recentAutoScroll && !rButtonOtherButtons && (currentTime - lastContextMenuCloseTime > 200) && (currentTime - lastAutoScrollTime > 1000) && (currentTime - lastSaveTime > 1000))
    {
        Sleep(50)
        Send("{RButton}")
        FileAppend("RButton released: Sent RButton (context menu) at " currentTime ", mButtonPressed=" mButtonPressed ".\n", logFile)
    }
    else
    {
        FileAppend("RButton released: Skipped context menu due to mButtonPressed=" mButtonPressed ", recentAutoScroll=" recentAutoScroll ", rButtonOtherButtons=" rButtonOtherButtons ", lastContextMenuCloseTime=" lastContextMenuCloseTime ", lastAutoScrollTime=" lastAutoScrollTime ", lastSaveTime=" lastSaveTime ".\n", logFile)
        CloseClipboardInterfaces()
    }
    mButtonPressed := false
    recentAutoScroll := false
    rButtonOtherButtons := false
    FileAppend("RButton Up: mButtonPressed=" mButtonPressed ", rButtonOtherButtons=" rButtonOtherButtons ".\n", logFile)
    return
}

LButton::
{
    global autoScrollActive, mButtonPressed, scrollCount, rButtonPressCount, copyTriggered, saveTriggered, recentAutoScroll, lastAutoScrollTime, lastSaveTime, xButton1OtherButtons, xButton2OtherButtons, rButtonOtherButtons
    if (autoScrollActive)
    {
        autoScrollActive := false
        scrollSpeed := 0
        SetTimer(AutoScroll, 0)
        Send("{LButton up}")
        mButtonPressed := true
        recentAutoScroll := true
        lastAutoScrollTime := A_TickCount
        CloseClipboardInterfaces()
        FileAppend("LButton pressed during auto-scroll. Reset rButtonPressCount to 0 at " A_TickCount ".\n", logFile)
        return
    }
    if GetKeyState("XButton2", "P")
    {
        saveTriggered := true
        mButtonPressed := true
        xButton2OtherButtons := true
        Send("^s")
        lastSaveTime := A_TickCount
        FileAppend("LButton pressed with XButton2 held: Sent Ctrl+S (save) at " lastSaveTime ".\n", logFile)
        KeyWait("LButton")
        mButtonPressed := false
        CloseClipboardInterfaces()
        return
    }
    if GetKeyState("RButton", "P")
        rButtonOtherButtons := true
    if GetKeyState("XButton1", "P")
        xButton1OtherButtons := true
    if GetKeyState("MButton", "P")
        xButton1OtherButtons := true
        xButton2OtherButtons := true
    mButtonPressed := true
    scrollCount := 0
    rButtonPressCount := 0
    FileAppend("LButton pressed: mButtonPressed=" mButtonPressed ".\n", logFile)
    Send("{LButton down}")
    return
}

LButton Up::
{
    global autoScrollActive, mButtonPressed, rButtonPressCount, autoScrollMode, recentAutoScroll, lastAutoScrollTime, saveTriggered
    if (autoScrollMode = 1 && autoScrollActive)
    {
        autoScrollActive := false
        scrollSpeed := 0
        SetTimer(AutoScroll, 0)
        mButtonPressed := true
        recentAutoScroll := true
        lastAutoScrollTime := A_TickCount
        CloseClipboardInterfaces()
        FileAppend("LButton released: Auto-scroll stopped in Mode 1.\n", logFile)
    }
    Send("{LButton up}")
    rButtonPressCount := 0
    mButtonPressed := false
    saveTriggered := false
    CloseClipboardInterfaces()
    FileAppend("LButton released: Reset rButtonPressCount to 0, mButtonPressed=" mButtonPressed ", saveTriggered=" saveTriggered ".\n", logFile)
    return
}
