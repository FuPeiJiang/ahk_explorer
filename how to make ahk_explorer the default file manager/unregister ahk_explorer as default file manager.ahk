#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, force
ListLines Off
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetBatchLines, -1
#KeyHistory 0

RegWrite % "REG_SZ", % "HKEY_CLASSES_ROOT\Directory\shell",, % "none"
RegDelete % "HKEY_CLASSES_ROOT\Directory\shell\ahk_explorer"

RegWrite % "REG_SZ", % "HKEY_CLASSES_ROOT\Drive\shell",, % "none"
RegDelete % "HKEY_CLASSES_ROOT\Drive\shell\ahk_explorer"

Exitapp

f3::Exitapp