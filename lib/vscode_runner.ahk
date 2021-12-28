#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, force
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.
SetBatchLines, -1
#KeyHistory 0
ListLines Off
SetWinDelay, -1
SetControlDelay, -1

FileRead settingsTxt, % A_AppData "\ahk_explorer_settings\settings.txt"
settingsArr:=StrSplit(settingsTxt, "`n", "`r")
vscodePath:=settingsArr[2]


if (A_Args.Length() > 1) {
    Msgbox % "more than 1 argument passed, please tell me your use case here"
    ExitApp
}

if (A_Args.Length() == 1) {
    vscodeRun(A_Args[1])
}

OnMessage(0x4A, "WM_COPYDATA_READ")

return

vscodeRun(filePath) {
    global vscodePath

    fileExist:=FileExist(filePath)
    if (!fileExist)
        ExitApp
    ;if file and not Dir
    if !InStr(fileExist, "D") {
        SplitPath, % filePath, , , OutExtension
        if (OutExtension!="code-workspace") {
            if !WinExist("ahk_exe Code.exe") {
                Run % """" vscodePath """"
                WinWait % "ahk_exe Code.exe"
            }
        }
    }
    Run % """" vscodePath """ """ filePath """"
    WinActivate % "ahk_exe Code.exe"
}

WM_COPYDATA_READ(wp, lp) {
    global
    data := StrGet(NumGet(lp + A_PtrSize*2), "UTF-16")
    RegExMatch(data, "s)(.*)\|(\d+)", match)

    if (match2==1) {
        vscodeRun(match1)
    }
}

f3::Exitapp

