cMsgbox(Atext)
{
    global widthOfCustomMsgboxGuiOk, vOkCustomMsgboxGui, gOkCustomMsgboxGui, CustomMsgboxGuiHwnd
    DetectHiddenWindowsBak:=A_DetectHiddenWindows
    DetectHiddenWindows, On
    if WinExist("ahk_id " CustomMsgboxGuiHwnd) {
    WinWaitClose, % "ahk_id " CustomMsgboxGuiHwnd
    }
    DetectHiddenWindows, %DetectHiddenWindowsBak%

    Gui, CustomMsgbox:New, +hwndCustomMsgboxGuiHwnd
    Gui, CustomMsgbox:Default
    Gui,Font,s10,Consolas
    gui, add, text,,%Atext%
    widthOfCustomMsgboxGuiOk:=100
    gui, add, button, w%widthOfCustomMsgboxGuiOk% +default vvOkCustomMsgboxGui ggOkCustomMsgboxGui,ok
    GuiControl, -Redraw, vOkCustomMsgboxGui
    gui, show
}

CustomMsgboxGuiClose:
    gui, Destroy
return
gOkCustomMsgboxGui:
    gui, Destroy
return

CustomMsgboxguisize:
    WinGetPos , , , customMsgboxWidth,, ahk_id %CustomMsgboxGuiHwnd%
    GuiControl, +Redraw, vOkCustomMsgboxGui
    GuiControl, Move, vOkCustomMsgboxGui, % "x" customMsgboxWidth/2 - widthOfCustomMsgboxGuiOk/2
return