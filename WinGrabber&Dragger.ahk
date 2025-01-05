#NoTrayIcon

CoordMode "Mouse", "Screen"

#LButton::
{
    ; 1. check where the mouse position is in the active windows
    ;    (upper edge, lower edge, left/right edge
    ; 2. if there safe positions on the Click
    ; 3. reduce window size and adapt position so that 
    ;    a resizing takes place depending on which edge was grabbed
    ;    when the mouse moves
    
    try
    {
        ; Load the crosshair cursor (IDC_CROSS = 32515)
        hCrossCursor := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32646, "Ptr")
        
        hHorResizeCursor := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32644, "Ptr")
        hVertResizeCursor := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32645, "Ptr")
        hDiagResizeNWSECursor := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32642, "Ptr")
        hDiagResizeNESWCursor := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32643, "Ptr")
        
        MouseGetPos(&StartX, &StartY, &ActiveWin)
        
        if (ActiveWin == 0)
        {
            return
        }

        WinGetPos(&WinStartX, &WinStartY, &WinStartWidth, &WinStartHeight, ActiveWin)

        RightGrab := False
        LeftGrab := False
        TopGrab := False
        BottomGrab := False
        CenterGrab := True
        
        if (StartX - WinStartX > WinStartWidth * 0.75)
        {
            RightGrab := True
        }
        if (StartX - WinStartX < WinStartWidth * 0.25)
        {
            LeftGrab := True
        }
        if (StartY - WinStartY > WinStartHeight * 0.75)
        {
            BottomGrab := True
        }
        if (StartY - WinStartY < WinStartHeight * 0.25)
        {
            TopGrab := True
        }
        CenterGrab := !TopGrab and !BottomGrab and !RightGrab and !LeftGrab
        
        
        hCursorToUse := hCrossCursor
        if ((RightGrab or LeftGrab) and not (BottomGrab or TopGrab))
        {
            hCursorToUse := hHorResizeCursor
        }
        if ((BottomGrab or TopGrab) and not (RightGrab or LeftGrab))
        {
            hCursorToUse := hVertResizeCursor
        }
        if ((RightGrab and TopGrab) or (LeftGrab and BottomGrab))
        {
            hCursorToUse := hDiagResizeNWSECursor
        }
        if ((RightGrab and BottomGrab) or (LeftGrab and TopGrab))
        {
            hCursorToUse := hDiagResizeNESWCursor
        }
        
        ; Capture the mouse to ensure smooth tracking
        DllCall("SetCapture", "Ptr", ActiveWin)
        
        while GetKeyState("LButton", "P")
        {
            MouseGetPos(&CurX, &CurY)
            
            NewWidth := WinStartWidth
            NewHeight := WinStartHeight
            
            if (RightGrab)
            {
                NewWidth := WinStartWidth + (CurX - StartX)
            }
            if (LeftGrab)
            {
                NewWidth := WinStartWidth - (CurX - StartX)
            }
            if (BottomGrab)
            {
                NewHeight := WinStartHeight + (CurY - StartY)
            }
            if (TopGrab)
            {
                NewHeight := WinStartHeight - (CurY - StartY)
            }
            
            NewWinX := WinStartX
            NewWinY := WinStartY

            if (LeftGrab or CenterGrab)
            {
                NewWinX += (CurX - StartX)
            }
            if (TopGrab or CenterGrab)
            {
                NewWinY += (CurY - StartY)
            }
            
            ; Resize the window using DllCall for better performance
            DllCall("SetWindowPos", "Ptr", ActiveWin, "Ptr", 0, 
                    "Int", NewWinX, "Int", NewWinY, "Int", 
                    NewWidth, "Int", NewHeight, "UInt", 
                    0x0040)
            ; Doesn't work for some reason, probably 
            ; because it gets overriden immediately by the window class 
            ; cursor
            DllCall("SetCursor", "Ptr", hCursorToUse)
        }
        ; Release the mouse capture
        DllCall("ReleaseCapture")
    
    }
}

#RButton::
{

}

>^Left::    MoveActiveWindowBy(-10,   0)
>^Right::   MoveActiveWindowBy(+10,   0)
>^Up::      MoveActiveWindowBy(  0, -10)
>^Down::    MoveActiveWindowBy(  0, +10)

MoveActiveWindowBy(x, y) {
    WinExist("A") ; Make the active window the Last Found Window  
    WinGetPos(&current_x, &current_y)
    WinMove(current_x + x, current_y + y)
}