#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, force
ListLines Off
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetBatchLines, -1
#KeyHistory 0

; [HKEY_CLASSES_ROOT\Directory\shell\ahk_explorer\command]
; "C:\Program Files\AutoHotkey\AutoHotkey.exe" "C:\Users\User\Documents\GitHub\ahk_explorer\ahkExplorerPassPath.ahk" "%1"
SplitPath, A_ScriptDir,, Ahk_Explorer_Dir

RegWrite % "REG_SZ", % "HKEY_CLASSES_ROOT\Directory\shell",, % "ahk_explorer"
RegWrite % "REG_SZ", % "HKEY_CLASSES_ROOT\Directory\shell\ahk_explorer\command",, % """C:\Program Files\AutoHotkey\AutoHotkey.exe"" """ Ahk_Explorer_Dir "\ahkExplorerPassPath.ahk"" ""%1"""

RegWrite % "REG_SZ", % "HKEY_CLASSES_ROOT\Drive\shell",, % "ahk_explorer"
RegWrite % "REG_SZ", % "HKEY_CLASSES_ROOT\Drive\shell\ahk_explorer\command",, % """C:\Program Files\AutoHotkey\AutoHotkey.exe"" """ Ahk_Explorer_Dir "\ahkExplorerPassPath.ahk"" ""%1"""

Exitapp

f3::Exitapp