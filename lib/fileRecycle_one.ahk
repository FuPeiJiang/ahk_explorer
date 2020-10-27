#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, Off
    SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

FileRecycle, % A_Args[1]
if (ErrorLevel=1) {
    p("File is in use or Requires PERMISSION to delete")
    ExitApp
}

; SoundPlay, *-1

ExitApp

f3::Exitapp