#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, force
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.
SetBatchLines, -1
#KeyHistory 0
ListLines Off
SetWinDelay, -1
SetControlDelay, -1

if (A_Args.Length() > 1) {
    Msgbox % "more than 1 argument passed, please tell me your use case here"
    ExitApp
}

; https://gist.github.com/Longhanks/8a317f92f9bfa4f3c8c8020c4678f1cf
flags:="--enable-accelerated-video-decode --enable-accelerated-mjpeg-decode --enable-features=VaapiVideoDecoder,CanvasOopRasterization --enable-gpu-compositing --enable-gpu-rasterization --enable-native-gpu-memory-buffers --enable-oop-rasterization --canvas-oop-rasterization --enable-raw-draw --use-vulkan --enable-zero-copy --ignore-gpu-blocklist"
vscodePath:=getVscodePath()
getVscodePath() {
    FileRead settingsTxt, % A_AppData "\ahk_explorer_settings\settings.txt"
    settingsArr:=StrSplit(settingsTxt, "`n", "`r")
    return settingsArr[2]
}

if (A_Args.Length() == 1) {
    vscodeRun(A_Args[1])
}

OnMessage(0x4A, "WM_COPYDATA_READ")

return

vscodeRun(filePath) {
    global vscodePath, flags

    ; fileExist:=FileExist(filePath)
    ; if (!fileExist)
        ; ExitApp
    ;if file and not Dir
    ; if !InStr(fileExist, "D") {
        ; SplitPath, % filePath, , , OutExtension
        ; if (OutExtension!="code-workspace") { ;.code-workspace will actually open a folder
            ; if !WinExist("ahk_exe Code.exe") {
                ; Run % """" vscodePath """ " flags
                ; WinWait % "ahk_exe Code.exe"
                ; WinMaximize % "ahk_exe Code.exe"
            ; }
        ; }
    ; }
    Run % """" vscodePath """ """ filePath """ " flags
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

