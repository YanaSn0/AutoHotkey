; WheelUp: Handle auto-scroll when RButton is held, preserve modifier+Wheel behaviors
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
        else if scrollCount = 4
        {
            ; Fourth scroll: Speed 4 (15ms, ~66.67 scrolls/sec)
            autoScrollInterval := 15
            SetTimer AutoScroll, autoScrollInterval
        }
    }
    else
    {
        if GetKeyState("Ctrl", "P")  ; Check if Ctrl is held
        {
            Send "{Ctrl down}"
            Send "{WheelUp}"  ; Send Ctrl + WheelUp for zooming
            Send "{Ctrl up}"
        }
        else if GetKeyState("Shift", "P")  ; Check if Shift is held
        {
            Send "{Shift down}"
            Send "{WheelUp}"  ; Send Shift + WheelUp for horizontal scrolling
            Send "{Shift up}"
        }
        else if GetKeyState("Alt", "P")  ; Check if Alt is held
        {
            Send "{Alt down}"
            Send "{WheelUp}"  ; Send Alt + WheelUp for app-specific actions
            Send "{Alt up}"
        }
        else
        {
            Send "{WheelUp}"  ; Normal scroll up
        }
    }
    return
}

; WheelDown: Handle auto-scroll when RButton is held, preserve modifier+Wheel behaviors
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
        else if scrollCount = 4
        {
            ; Fourth scroll: Speed 4 (15ms, ~66.67 scrolls/sec)
            autoScrollInterval := 15
            SetTimer AutoScroll, autoScrollInterval
        }
    }
    else
    {
        if GetKeyState("Ctrl", "P")  ; Check if Ctrl is held
        {
            Send "{Ctrl down}"
            Send "{WheelDown}"  ; Send Ctrl + WheelDown for zooming
            Send "{Ctrl up}"
        }
        else if GetKeyState("Shift", "P")  ; Check if Shift is held
        {
            Send "{Shift down}"
            Send "{WheelDown}"  ; Send Shift + WheelDown for horizontal scrolling
            Send "{Shift up}"
        }
        else if GetKeyState("Alt", "P")  ; Check if Alt is held
        {
            Send "{Alt down}"
            Send "{WheelDown}"  ; Send Alt + WheelDown for app-specific actions
            Send "{Alt up}"
        }
        else
        {
            Send "{WheelDown}"  ; Normal scroll down
        }
    }
    return
}
