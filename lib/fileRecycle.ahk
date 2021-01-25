#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, force
    SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

currentDir:=A_Args[1]
A_Args.RemoveAt(1)
for k, v in A_Args {
    FileRecycle, % currentDir "\" v
    if (ErrorLevel=1) {
        Msgbox, % "File is in use or Requires PERMISSION to delete"
        ExitApp
    }
}

SoundPlay, *-1

ExitApp

f3::Exitapp