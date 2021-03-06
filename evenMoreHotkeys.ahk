﻿#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, force
    SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

ahkTestsPath=C:\Users\Public\AHK\notes\tests
nameOfNewAHK=test

$#e::
    minimizeCortana()
    SetTitleMatchMode, 2
    
    if winactive("ahk_explorer ahk_class AutoHotkeyGUI")
    {
        winactivate, ahk_exe code.exe
    }
    else if winexist("ahk_explorer ahk_class AutoHotkeyGUI")
    {
        winactivate
    }
    else
    {
        run, "ahk_explorer.ahk" ;change this to your path if it doesn't work
    }
    SetTitleMatchMode, 1
return

$#1:: ;you can put a shortcut of script in "shell:common startup" or simply "shell:startup"
    minimizeCortana()
    openInAhkExplorer("C:\Users\Public\AHK") 
return

$#+d::
    minimizeCortana()
    openInAhkExplorer("C:\Users\User\Downloads") 
return
$^+1::
    minimizeCortana()
    openInAhkExplorer("C:\Users\Public\AHK\notes\tests") 
return

$^+a:: ;create a test.ahk at currentDir. will become test2.ahk if exist... test3, test4
    bak:=clipboard
    desktop:=false
    WinGet, OutputVar, ProcessName, A
    if (OutputVar="Explorer.EXE")
    {
        WinGetClass, OutputVar2, A
        if (OutputVar2="Shell_TrayWnd" or OutputVar2="WorkerW")
        {
            desktop:=true
        }
        pathOfAHK := Explorer_GetPath()
    }
    else
    {
        SetTitleMatchMode, 2
        if winactive("ahk_explorer ahk_class AutoHotkeyGUI") {
            SetTitleMatchMode, 1
            pathOfAHK:=getAhk_ExplorerTitle()
        }
        else {
            SetTitleMatchMode, 1
            pathOfAHK:=ahkTestsPath
        }
    }
    fullPathOfAHK := GetPathWithIncrement(pathOfAHK . "\" . nameOfNewAHK . ".ahk", newAhkScript_saveTheNumberOnEnd)
    if (desktop)
    {
        SplitPath, fullPathOfAHK,,,,OutNameNoExt
        clipboard:=OutNameNoExt
        click, right
        sleep, 50
        send, wa
        send, ^v
        send, {enter}
        sleep, 200
    }
    else
    {
        FileCopy, C:\WINDOWS\SHELLNEW\Template.ahk , %fullPathOfAHK% 
    }
    fullPathOfAHK:= SurroundByQuotes(fullPathOfAHK)
    toRun:= """C:\Users\User\AppData\Local\Programs\Microsoft VS Code\Code.exe"" " . fullPathOfAHK
    run, %toRun% 
    WinWaitActive, ahk_exe Code.exe
    send, ^g6{enter}
    clipboard:=bak 
return

$XButton2::
    bak:=ClipBoardAll
    if WinActive("ahk_exe chrome.exe") or winactive("ahk_exe firefox.exe")
    {
        send, {shift down}
            Send, {MButton}
        send, {Shift Up}
            return
    }
    else
    {
        SetTitleMatchMode, 2
        if winactive("ahk_explorer ahk_class AutoHotkeyGUI") {
            click,
            ; sleep, 5
            keybd_eventDown("ctrl")
            keybd_eventDown("shift")
                keybd_event("c")
            keybd_eventUp("shift")
                keybd_eventUp("ctrl")
            sleep, 5
            if (clipboard="") {
                clipboard:=getAhk_ExplorerTitle()
                ; p("nothing")
                ; return
                ; send, /{ctrl down}c{ctrl up}
                ; keybd_event("/")
                ; keybd_eventDown("ctrl")
                ; keybd_event("c")
                ; keybd_eventUp("ctrl")
                ; sleep, 20
            }
            toRun:= """C:\Users\User\AppData\Local\Programs\Microsoft VS Code\Code.exe"" """ clipboard """"
            run, %toRun%
        }
        else {
            click,
            sleep, 10
            
            selected:=Explorer_GetSelected()
            
            SplitPath,selected, , , OutExtension
            selected:=SurroundByQuotes(selected)
            
            if (OutExtension = "lnk" or OutExtension = "url")
            {
                send, {alt down}
                click 
                send, {alt up}
                
            }
            else if (OutExtension = "txt")
            {
                
                If WinExist("ahk_class Notepad++")
                {
                    run, %selected%
                }
                else
                {
                    DetectHiddenWindows, on
                    If WinExist("ahk_class Notepad++")
                    {
                        WinHide, ahk_class Notepad++
                        Winshow, ahk_class Notepad++
                        DetectHiddenWindows, off
                        WinWait, ahk_class Notepad++
                        WinActivate, ahk_class Notepad++
                        run, %selected%
                    }
                    else
                    {
                        DetectHiddenWindows, off
                        run, %selected%
                    }
                }
            }
            else ;NOTE THAT VSCODE CANT OPEN ITSELF
            {
                if (selected="""""")
                {
                    clipboard:=""
                    send, {ctrl down}lc{ctrl up}
                    sleep, 100
                    selected:= clipboard
                    ;selected :=Explorer_GetPath() ;for commander
                    selected:=SurroundByQuotes(selected) 
                    
                }
                toRun:= """C:\Users\User\AppData\Local\Programs\Microsoft VS Code\Code.exe"" " . selected
                If (ok:=WinExist("ahk_exe Code.exe"))
                {
                    winactivate
                    run, %toRun%
                }
                else
                {
                    
                    DetectHiddenWindows, on
                    If WinExist("ahk_exe Code.exe")
                    {
                        WinHide
                        sleep, 100
                        WinShow
                        DetectHiddenWindows, off
                        winwait, ahk_exe Code.exe
                        WinActivate, ahk_exe Code.exe
                        run, %toRun%
                        
                    }
                    else
                    {
                        DetectHiddenWindows, off
                        run, %toRun%
                    }
                }
            }
        }
        
        SetTitleMatchMode, 1
        
    }
    clipboard:=bak
return

$XButton1::
    WinGet, OutputVar, ProcessName, A
    
    If (OutputVar="chrome.exe")
    {
        clipBackup = %clipboard%
        clipboard := "" ; Empty the clipboard
        Send, ^c
        clipwait, 0.1
        if errorlevel
        {
            clipboard = %clipBackup%
            Send, ^t
            sleep, 5
            Send,^v{enter}
            return
        }
        else
        {
            Send, ^t
            sleep, 5
            Send,^v{enter}
            return
        }
        
    }
    
    clibakup:=clipboard
    clipboard= ;i have no clue why ;click for the FILE
    Send, ^c
    sleep, 100
    clipBackup := clipboard
    
    
    
    if (clipBackup != "" and !InStr(clipBackup, ":\") ) ; = ""
    {
        if WinExist("ahk_exe firefox.exe")
        {
            runCommand := """" . "C:\Program Files\Firefox Developer Edition\firefox.exe" . """ " . """" . "https://www.google.com/search?q=" . clipBackup . """"
            Run, %runCommand%
            return
        }
        runCommand := """" . "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" . """ " . """" . "https://www.google.com/search?q=" . clipBackup . """"
        Run, %runCommand%
        return
    }
    
    click
    
    if (OutputVar="Explorer.EXE")
    {
        yDoh := SurroundByQuotes(Explorer_GetSelected())
        
        if (yDoh = """""") ; = ""
        {
            WinGet, pathActiveWindow, ProcessPath, A
            yDoh := """" . pathActiveWindow . """"
            if (yDoh = """" . "C:\Windows\explorer.exe" . """")
            {
                dir := Explorer_GetPath()
                run, %ComSpec% /k cd %dir%
                clipboard:=clibakup
                return
            }
            return
        }
        else
        {
            ClipBoard:=yDoh
        }
    } else {
        SetTitleMatchMode, 2
        if winactive("ahk_explorer ahk_class AutoHotkeyGUI") {
            dir:=getAhk_ExplorerTitle()
            run, %ComSpec% /k cd %dir%
            clipboard:=clibakup
            return
        }
        SetTitleMatchMode, 1
    }
    
    
    */
return

f3::Exitapp

;start of functions________________________________________________
minimizeCortana()
{
    If WinActive("Cortana")
    {
        send, {esc}
    }
}
openInAhkExplorer(path) 
{
    SetTitleMatchMode, 2
    if winExist("ahk_explorer ahk_class AutoHotkeyGUI")
        send_string(path)
    else
        run, AutoHotkeyU64 "C:\Users\User\Documents\GitHub\ahk_explorer\ahkExplorerPassPath.ahk" "%path%"
    SetTitleMatchMode, 1
}

SurroundByQuotes(string)
{
    string := """" . string . """"
return string
}

keybd_event(key, duration=5)
{
    dllcall("keybd_event", uchar, GetKeyVK(key), uchar, GetKeySC(key), uint, 0, ptr, 0)
    sleep duration
    dllcall("keybd_event", uchar, GetKeyVK(key), uchar, GetKeySC(key), uint, 2, ptr, 0)
}

keybd_eventDown(key)
{
    dllcall("keybd_event", uchar, GetKeyVK(key), uchar, GetKeySC(key), uint, 0, ptr, 0)
}

keybd_eventUp(key)
{
    dllcall("keybd_event", uchar, GetKeyVK(key), uchar, GetKeySC(key), uint, 2, ptr, 0)
}
getAhk_ExplorerTitle() {
    WinGetTitle, OutputVar, A
return SubStr(OutputVar, 1 , StrLen(OutputVar)-15)
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
    GetPathWithIncrement(element, saveTheNumberOnEnd)
    {
        if (checkIfSurroundedByQuotes(element))
            copyPath := removeFirstAndLastFromString(element)
        else
            copyPath := element
        
        number:=""
        
        SplitPath, copyPath ,OutFileName ,OutDir , OutExtension1, OutNameNoExt
        
        numberFromEnd := getNumberFromEnd(OutNameNoExt)
        
        OutNameNoExt := SubStr(OutNameNoExt, 1 , StrLen(OutNameNoExt)-StrLen(numberFromEnd))
        if (saveTheNumberOnEnd)
        {
            number := numberFromEnd ; if number := "" den ok
        }
        
        
        
        if (OutExtension1)
        {
            OutExtension1:= "." . OutExtension1
        }
        
        
        
        idkPath := OutDir . "\" . OutNameNoExt
        
        idkBOOL:=false
        bruh := idkPath . 1 . OutExtension1	
        if FileExist(bruh)
            idkBOOL:= true
        
        
        loop 
        {
            
            pastePath := idkPath . number . OutExtension1		
            
            if FileExist(pastePath) or (idkBOOL)
            {
                idkBOOL:=false
                
                if (number = "")
                    number++
                number++
                continue
            }
            break			
            
        }
        
        return pastePath
    }
        checkIfSurroundedByQuotes(string)
    {
        left:= SubStr(string,1, 1)
        right:= SubStr(string,0)
        if (left = """" and right = """")
            return true
        return false
    }
        removeFirstAndLastFromString(string)
    {
        string := SubStr(string,1, -1)
        string := SubStr(string,2)
        return string
    }
        getNumberFromEnd(string)
    {
        i:=0
        lastChar1:=""
        
        loop % StrLen(string)
        {	
            lastChar := SubStr(string, i) ;index 0 
            If lastChar is not Number
            {
                lastChar1 := SubStr(lastChar, 2)
                break
                
            }
            i--
            
        }
        return lastChar1
    }