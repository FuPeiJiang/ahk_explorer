#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, force
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.
SetBatchLines, -1
#KeyHistory 0
ListLines Off

;CHANGE .\ahk_explorer.ahk TO THE LONGPATH OF AHK_EXPLORER if THIS script is in another folder
#+d::
openInAhkExplorer("C:\Users\User\Downloads") 
return
#1::
openInAhkExplorer("C:\Users\Public\AHK") 
return

openInAhkExplorer(path) 
{
  titleMatchModeBak:=A_TitleMatchMode
  SetTitleMatchMode, 2
  if winExist("ahk_explorer ahk_class AutoHotkeyGUI")
    send_string(path)
  else
    run % """" A_AhkPath """ "".\ahk_explorer.ahk"" """ path """"
    ;CHANGE .\ahk_explorer.ahk TO THE LONGPATH OF AHK_EXPLORER if THIS script is in another folder
  SetTitleMatchMode % titleMatchModeBak
}

send_string(stringToSend) 
{
    stringToSend .= "|1"
    VarSetCapacity(message, size := StrPut(stringToSend, "UTF-16")*2, 0)
    StrPut(stringToSend, &message, "UTF-16")
    VarSetCapacity(COPYDATASTRUCT, A_PtrSize*3)
    NumPut(size, COPYDATASTRUCT, A_PtrSize, "UInt")
    NumPut(&message, COPYDATASTRUCT, A_PtrSize*2)
    DetectHiddenWindows, On
    SetTitleMatchMode, 2
    SendMessage, WM_COPYDATA := 0x4A,, &COPYDATASTRUCT,, ahk_explorer.ahk ahk_class AutoHotkey
}

f3::Exitapp