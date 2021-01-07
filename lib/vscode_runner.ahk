#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, force
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.
SetBatchLines, -1
#KeyHistory 0
ListLines Off
SetWinDelay, -1
SetControlDelay, -1

vscodePath:="C:\Users\User\AppData\Local\Programs\Microsoft VS Code\Code.exe"

if (A_Args>1) {
    Msgbox % "more than 1 argument passed, please tell me your use case here"
    ExitApp
}
; p(argPath)
fileExist:=FileExist(A_Args[1])
if (!fileExist)
    ExitApp
;if file and not Dir
if !InStr(fileExist, "D") {
    SplitPath, % A_Args[1], , , OutExtension
    if (OutExtension!="code-workspace") {
        if !WinExist("ahk_exe Code.exe") {
            Run, % """" vscodePath """"
            WinWait, % "ahk_exe Code.exe"
        }
    }
}
Run, % """" vscodePath """ """ A_Args[1] """"

ExitApp

f3::Exitapp