cMsgbox(Atext)
{
    global widthOfCustomMsgboxGuiOk, vOkCustomMsgboxGui, gOkCustomMsgboxGui, CustomMsgboxGuiHwnd, CustomMsgboxGuiText
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
    CustomMsgboxGuiText:=Atext
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

#if winactive("ahk_id " CustomMsgboxGuiHwnd)
^c::
    clipboard:=CustomMsgboxGuiText
    SoundPlay, *-1
return