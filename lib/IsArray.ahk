#NoEnv ; Recommended for performance and compatibility with future AutoHotKey23 releases.
#SingleInstance, force
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.

;https://www.autohotkey.com/boards/viewtopic.php?t=64332#p275856 by jeeswg
IsArray(oArray)
{
    local
    if !ObjCount(oArray)
        return 1
    if !(ObjCount(oArray) = ObjLength(oArray))
        || !(ObjMinIndex(oArray) = 1)
    return 0
    for vKey in oArray
        if !(vKey = A_Index)
        return 0
    return 1
}