#SingleInstance Force  ; Ensures only one instance of the script is running

; Initialize global variables at script startup
SetTimer(InitializeGlobals, -1)

InitializeGlobals()
{
    global lastRButtonTime := 0
    global doubleClickInterval := 300  ; Double-click interval in milliseconds
    global rButtonPressTime := 0  ; Track the time of the first RButton press
    global lButtonHeld := false  ; Track if LButton is held
    global mButtonPressed := false  ; Track if MButton was pressed during RButton hold
    return
}

; XButton1: Open Ditto
XButton1::
{
    Send("^``")  ; Ctrl + ` (backtick) to open Ditto
    return
}

; XButton2: Open clipboard history
XButton2::
{
    Send("{LWin down}")  ; Press the Windows key
    Send("v")            ; Press the V key
    Send("{LWin up}")    ; Release the Windows key
    return
}

; Middle mouse button: Paste or Enter if RButton is held
MButton::
{
    global mButtonPressed
    if (GetKeyState("RButton", "P"))  ; Check if RButton is physically held
    {
        Send("{Enter}")  ; Send Enter key
        mButtonPressed := true  ; Mark that MButton was pressed during RButton hold
    }
    else
    {
        Send("^v")  ; Ctrl + V (paste)
        Sleep(50)  ; Small delay to ensure the paste completes properly
    }
    return
}

; Right mouse button handler: Check if LButton is held or MButton was pressed
RButton::
{
    global lastRButtonTime, doubleClickInterval, rButtonPressTime, lButtonHeld, mButtonPressed

    ; Check if LButton is held at the start of the RButton press
    lButtonHeld := GetKeyState("LButton", "P")

    if (lButtonHeld)
    {
        currentTime := A_TickCount
        if (currentTime - lastRButtonTime <= doubleClickInterval)
        {
            ; Double-click detected
            Send("^a")  ; Ctrl + A (select all)
            lastRButtonTime := 0  ; Reset the timer
            rButtonPressTime := 0  ; Reset the first press time
            KeyWait("RButton")  ; Wait for RButton to be released to consume the event
        }
        else
        {
            ; First press: Execute the copy action immediately
            Send("^c")  ; Ctrl + C (copy)
            lastRButtonTime := currentTime
            rButtonPressTime := currentTime
            KeyWait("RButton")  ; Wait for RButton to be released to consume the event
        }
    }
    else
    {
        ; Reset mButtonPressed at the start of RButton press
        mButtonPressed := false
        ; Wait for RButton release and monitor MButton presses
        KeyWait("RButton")  ; Wait for the physical button to be released
        ; Only simulate right-click if MButton was not pressed
        if (!mButtonPressed)
        {
            Send("{RButton}")  ; Simulate right-click to open context menu
        }
    }
    return
}
