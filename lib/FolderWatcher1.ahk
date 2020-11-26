#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, force
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.

OnMessage(0x4A, "WM_COPYDATA_READ")
return

CallbackWatch()
{

}

startWatchFolder(WatchedFolder)
{
    global
    ; Pause
    WatchFolder(WatchedFolder, "**DEL")
    If !WatchFolder(WatchedFolder, CallbackWatch, 0, 3) { ;files and folders
        MsgBox, 0, Error, Call of WatchFolder() failed!
        Return
    }
}
stopWatchFolder(WatchedFolder) 
{
    global
    WatchFolder(WatchedFolder, "**DEL")
}

WM_COPYDATA_READ(wp, lp) {
    global
    data := StrGet(NumGet(lp + A_PtrSize*2), "UTF-16")
    RegExMatch(data, "s)(.*)\|(\d+)", match)

    if (match2=1) {
        startWatchFolder(match1)
    } else if (match2=2) {
        StopWatchFolder(match1)
    } else {
        p("WatchFolder1: something went wrong")
    }
}
send_stringData(num, stringToSend:="") 
{
    stringToSend .= "|" num
    VarSetCapacity(message, size := StrPut(stringToSend, "UTF-16")*2, 0)
    StrPut(stringToSend, &message, "UTF-16")
    VarSetCapacity(COPYDATASTRUCT, A_PtrSize*3)
    NumPut(size, COPYDATASTRUCT, A_PtrSize, "UInt")
    NumPut(&message, COPYDATASTRUCT, A_PtrSize*2)
    DetectHiddenWindows, On
    SetTitleMatchMode, 2
    SendMessage, WM_COPYDATA := 0x4A,, &COPYDATASTRUCT,, ahk_explorer.ahk ahk_class AutoHotkey
}

; #include WatchFolder.ahk

#include %A_ScriptDir%\WatchFolder.ahk

f3::Exitapp