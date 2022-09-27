#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, force
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.
SetBatchLines, -1
#KeyHistory 0
ListLines Off

SetWinDelay, -1
SetControlDelay, -1

#MaxThreads, 20
#MaxThreadsPerHotkey, 4
SetTitleMatchMode, 2

FOLDERID_Downloads := "{374DE290-123F-4565-9164-39C4925E467B}"
RegRead, v, HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders, % FOLDERID_Downloads
VarSetCapacity(downloads, (261 + !A_IsUnicode) << !!A_IsUnicode)
DllCall("ExpandEnvironmentStrings", Str, v, Str, downloads, UInt, 260)
EcurrentDir1:=downloads
; EcurrentDir1:="C:\Users\Public\AHK\notes\tests"
; EcurrentDir1:="C:\Users\Public\AHK\notes\tests\File Watcher"
; EcurrentDir2:="C:\Users\Public\AHK"
; EcurrentDir1:="C:\Users\Public\AHK\notes\tests\New Folder"
EcurrentDir2:="C:\Users\Public\AHK\notes\tests\New Folder 3"
whichSide:=1

lastDir1:="C:"

for n, param in A_Args ; For each parameter:
{
    fileExist:=fileExist(param)
    if (fileExist) {
        if (InStr(fileExist, "D")) {
            EcurrentDir%whichSide%:=param

        } else {
            SplitPath, param, OutFileName, OutDir
            EcurrentDir%whichSide%:=OutDir
            toFocus:=OutFileName
            ;select file
        }
    }
    else {
        p("the folder or file you are trying to open doesn't exist`nyou were trying to open:`n" param)
    }
    break
}
;global vars
maxRows:=50
dirHistoryArr:=[[],[]]
undoHistoryArr:=[[],[]]
dirWatched:={}
global DROPEFFECT_NONE	:= 0
global DROPEFFECT_COPY	:= 1
global DROPEFFECT_MOVE	:= 2
global DROPEFFECT_LINK	:= 4
calculatefileSizes:=1
calculateDates:=1
doIcons:=1
global dropEffectFormat := DllCall("RegisterClipboardFormat", "Str", CFSTR_PREFERREDDROPEFFECT := "Preferred DropEffect", "UInt")

Gui, main:New, +hwndthisHwnd
thisUniqueWintitle:="ahk_id " thisHwnd
Gui, main:Default
Gui,Font, s10, Segoe UI

Gui, +LastFound
hw_gui := WinExist()

Gui, Margin, 0, 0

folderListViewWidth:=250
favoritesListViewWidth:=140

listViewWidth:=500

Gui, Add, ListView, r10 w%folderListViewWidth% y0 x%favoritesListViewWidth% vfolderListView1_1 gfolderlistViewEvents1_1 AltSubmit ,Name
Gui, Add, ListView, r10 w%folderListViewWidth% x+0 y0 vfolderlistView2_1 gfolderlistViewEvents2_1 AltSubmit ,Name
Gui, Add, Edit, hwndEdithwnd1 r1 w%listViewWidth% y+0 x+-500 vvcurrentDirEdit1 gcurrentDirEdit1Changed, %EcurrentDir1%
Gui, Add, ListView, NoSort HwndhwndListview1 Count5000 r25 -WantF2 w%listViewWidth% vvlistView1 gglistViewEvents1 AltSubmit ,type|Name|Date|sortableDate|Size|sortableSize

Gui, Add, ListView, r10 w%folderListViewWidth% y0 x+0 vfolderListView1_2 gfolderlistViewEvents1_2 AltSubmit ,Name
Gui, Add, ListView, r10 w%folderListViewWidth% x+0 y0 vfolderlistView2_2 gfolderlistViewEvents2_2 AltSubmit ,Name
Gui, Add, Edit, hwndEdithwnd2 r1 w%listViewWidth% y+0 x+-500 vvcurrentDirEdit2 gcurrentDirEdit2Changed, %EcurrentDir2%
Gui, Add, ListView, NoSort HwndhwndListview2 Count5000 r25 -WantF2 w%listViewWidth% vvlistView2 gglistViewEvents2 AltSubmit ,type|Name|Date|sortableDate|Size|sortableSize

OnMessage(0x4A, "WM_COPYDATA_READ")

OnMessage(0x111, "HandleMessage" )
initIconStuff()


success:=_render_Current_Dir()
WatchFolder.init() ;init later to startup faster
if (success) {
    updateDirsToWatch()
    dirHistoryArr[whichSide].Push(lastDir%whichSide%)
}
lastDir%whichSide%:=EcurrentDir%whichSide%

;%appdata%\ahk_explorer_settings
FileRead, favoriteFolders, %A_AppData%\ahk_explorer_settings\favoriteFolders.txt
favoriteFolders:=StrSplit(favoriteFolders,"`n","`r")
Gui, Add, Button, % "w" favoritesListViewWidth " ggsettings x0 y212 h30", settings
Gui, Add, ListView, % "r" favoriteFolders.Length() " w" favoritesListViewWidth " x0 y242 nosort vfavoritesListView ggfavoritesListView AltSubmit ", Favorites
Gui, ListView, favoritesListView
GuiControl, -Redraw, favoritesListView
for k, v in favoriteFolders {
    SplitPath, v, OutFileName
    LV_Add(, OutFileName)
}
GuiControl, +Redraw, favoritesListView
Gui, Show

loadSettings()

FileRead, hotkeysToDisable, %A_AppData%\ahk_explorer_settings\hotkeysToDisable.txt
Loop, Parse, hotkeysToDisable, `n, `r
{
    if (InStr(A_LoopField, "#if") == 1) {
        expression:=SubStr(A_LoopField, 5)
        Hotkey If, % expression
    } else {
        Hotkey % A_LoopField,, Off
    }
}

;gsettings

VD.init() ;init later to startup faster

return

; f3::
Process, Close, %PID_getFolderSizes%
Exitapp
return

;labels
;Ltrim new folder name since it's invalid
gcreateFolder:
    ControlGetText, createFolderName,, % "ahk_id " folderCreationHwnd
    newCreateFolderName:=LTrim(createFolderName)
    if !(newCreateFolderName==createFolderName) {
        GuiControl, Text, vcreateFolder, % newCreateFolderName
    }
return

gsaveSettings:
    gui, settingsGui:Default
    gui, submit
    FileRecycle, %A_AppData%\ahk_explorer_settings\settings.txt
    FileAppend, %vsettings%, *%A_AppData%\ahk_explorer_settings\settings.txt
    loadSettings()
return

gsettings:
    Gui, settingsGui:Default
    FileRead, settingsTxt, %A_AppData%\ahk_explorer_settings\settings.txt
    if (!settingsGuiCreated)
    {
        settingsGuiCreated:=true
        editSize:=[1000, 200]
        textSize:=[190, editSize[2]]
        editPos:=[textSize[1]+30, 50]
        textPos:=[10, ZTrim(editPos[2]+1.5) ]
        guiSize:=[editSize[1]+textSize[1]+20, editPos[2]+editSize[2]+10]
        guiPos:=[A_ScreenWidth/2-guiSize[1]/2,A_ScreenHeight/2-guiSize[2]/2]
        Gui,Font,s12 w500 q5, Consolas

        Gui, add, button, ggsaveSettings,Save Settings
        Gui,add,Text, % "x" textPos[1] " y" textPos[2] " w" textSize[1] " h" textSize[2], peazipPath`nvscodePath`nBGColorOfSelectedPane`nAhk2ExePath`nspekPath
        Gui,add,Edit, % "x" editPos[1] " y" editPos[2] " w" editSize[1] " h" editSize[2] " vvsettings -wrap",%settingsTxt%
    } else {
        Guicontrol, text, vsettings,%settingsTxt%
    }
    Gui,show, % "x" guiPos[1] " y" guiPos[2] " w" guiSize[1] " h" guiSize[2] ,set_settings_GUI
return

gChangeDrive:
    index:=SubStr(A_GuiControl, 0)
    EcurrentDir%whichSide%:=drives[index] ":"
    renderCurrentDir()
return
multiRenameGuiGuiClose:
    Gui, Destroy
return
gmultiRenameApply:
    multiRenameNames:=getMultiRenameNames()
    multiRenameNamesBak:=multiRenameNames.Clone()
    namesToMultiRenameBak:=namesToMultiRename.Clone()

    for k, v in multiRenameNamesBak {
        toRenamePath := multiRenameDir "\" namesToMultiRenameBak[k]
        renamedPath := multiRenameDir "\" v

        renamedPathExists:=fileExist(renamedPath)
        if (renamedPathExists) {
            p("name already taken", renamedPathExists)
            break
        }
        toRenameExists:=fileExist(toRenamePath)
        if (toRenameExists) {
            if (InStr(toRenameExists, "D")) {
                FileMoveDir, %toRenamePath%, %renamedPath%
            } else {
                FileMove, %toRenamePath%, %renamedPath%
            }
            if ErrorLevel {
                p("file", toRenamePath "could not be renamed to", renamedPath)
                break
            }
            namesToMultiRename.RemoveAt(1)
            multiRenameNames.RemoveAt(1)
        } else {
            p("file to rename:", toRenamePath, "doesn't exist anymore")
            break
        }
    }
    multiRenamelength:=namesToMultiRename.Length()
    if (multiRenamelength) {
        Guicontrol, text, vmultiRenameTargets, % "|" array_ToVerticleBarString(namesToMultiRename)
        Guicontrol, text, vmultiRenamePreview, % "|" array_ToVerticleBarString(multiRenameNames)
    } else {
        Gui, Destroy
        setWhichSideFromDir(multiRenameDir)
        renderCurrentDir() ;refresh
    }
return
gmultiRenamePreview:
    Guicontrol, text, vmultiRenamePreview, % "|" array_ToVerticleBarString(getMultiRenameNames())
return
RemoveToolTip:
    ToolTip
return
TypingInRenameSimple:
    SetTimer, TypingInRenameSimple_TimerLabel, -0
return
TypingInRenameSimple_TimerLabel:
    ; if (A_TickCount < EditSearchSleep_tick) {
        ; return
    ; }
    ; EditSearchRunning:=false
    ; SetTimer, TypingInRenameSimple_TimerLabel, Off

    resizeRenameEdit()
    ControlGet, Outvar ,CurrentCol,,, % "ahk_id " RenameHwnd
    Outvar -=1
    Postmessage,0xB1, 0, 0,, % "ahk_id " RenameHwnd ;move caret to front to pan
    Postmessage,0xB1, % Outvar, % Outvar,, % "ahk_id " RenameHwnd ;move caret back to end
return

resizeRenameEdit() {
    global textRenamingSimple, RenameHwnd
    Gui, renameSimple:Default
    ControlGetText, textRenamingSimple,, % "ahk_id " RenameHwnd

    Size:=10
    textWidth:=getTextWidth(textRenamingSimple, Size, "Segoe UI")

    ; tooltip % textRenamingSimple

    if ((textWidth + 2*Size) > renameTextWidthLimit) {
        renameTextWidthLimit:=textWidth + 2*Size + 8*Size
        ; resize the Edit
        GuiControl Move,textRenamingSimple, W%renameTextWidthLimit%
        GuiWidth:=renameTextWidthLimit + 2
        ; resize the containing GUI
        Gui, Show, W%GuiWidth%
    }
}

;renameLabel
grenameFileLabel:
    fromButton:=true
renameFileLabel:
    if (canRename) {
        gui, renameSimple:Default
        gui, submit
        gui, main:Default
        noRenameError:=true

        if not(TextBeingRenamed==textRenamingSimple) { ;Case Sensitive
            if (stuffByName[textRenamingSimple].Count()) {
                noRenameError:=false
                p("file with same name")
            } else {
                SourcePath:=EcurrentDir%whichSide% "\" TextBeingRenamed
                fileExist:=FileExist(SourcePath)
                if (fileExist) {
                    DestPath:=EcurrentDir%whichSide% "\" textRenamingSimple

                    if (TextBeingRenamed=textRenamingSimple) { ;only different capitalization
                        randomPath:=generateRandomUniqueName(SourcePath,isDir)

                        if (isDir) {
                            FileMoveDir, %SourcePath%, %randomPath%
                        } else {
                            FileMove, %SourcePath%, %randomPath%
                        }
                        if ErrorLevel {
                            noRenameError:=false
                            p("file could not be renamed:illegal name or file in use")
                        }
                        SoundPlay, *-1

                        SourcePath:=randomPath
                    }

                    if (InStr(fileExist, "D")) {
                        FileMoveDir, %SourcePath%, %DestPath%
                    } else {
                        ; p("FileMove")
                        FileMove, %SourcePath%, %DestPath%
                    }
                    if ErrorLevel {
                        noRenameError:=false
                        p("file could not be renamed:illegal name or file in use")
                    }
                    SoundPlay, *-1
                }
            }
        }
        if (noRenameError)
        {
            canRename:=false
            gui, renameSimple:Default
            gui, destroy

            gui, main:Default
            if (fromButton) {
                ControlFocus,, % "ahk_id " hwndListview%whichSide%
            }
        } else {
            gui, main:Default

            gui, show

            gui, renameSimple:Default
            gui, show,,renamingWinTitle
        }
        fromButton:=false
    }
return

mainGuiClose:
    if GetKeyState("Shift") {
        Process, Close, %PID_getFolderSizes%
        Exitapp
    } else {
        Process, Close, %PID_getFolderSizes%
        Gui, main:Default
        Gui, Hide
    }
return

couldNotCreateFolder()
{
    global
    Gui, createFolder:Default
    creatingNewFolder:=true
    ControlSetText,, %vcreateFolder%, ahk_id %folderCreationHwnd%
    SendMessage, 0xB1, 0, -1,, % "ahk_id " folderCreationHwnd
    gui, createFolder: show,, create_folder
}
;new folder
;create folder
createLabel:
    gui, createFolder: submit
    toCreate:=EcurrentDir%whichSide% "\" vcreateFolder
    if (!fileExist(toCreate)) {
        FileCreateDir, %toCreate%
        if (ErrorLevel) {
            SoundPlay, *16
            p("Could not create Folder, illegal name or idk")
            couldNotCreateFolder()
        } else {
            Gui, main:Default
            SoundPlay, *-1
        }
    } else {
        SoundPlay, *16
        p("folder already exists")
        couldNotCreateFolder()
    }
return

createAndOpenLabel:
    gui, createFolder: submit
    toCreate:=EcurrentDir%whichSide% "\" vcreateFolder
    if (!fileExist(toCreate)) {
        FileCreateDir, %toCreate%
        if (ErrorLevel) {
            SoundPlay, *16
            p("Could not create Folder, illegal name or idk")
            couldNotCreateFolder()
        } else {
            EcurrentDir%whichSide%:=toCreate
            Gui, main:Default
            renderCurrentDir()
            SoundPlay, *-1
        }
    } else {
        SoundPlay, *16
        p("folder already exists")
        couldNotCreateFolder()
    }
return

gfavoritesListView:
    if (A_GuiEvent = "DoubleClick") {
        Gui, ListView, favoritesListView
        doubleClickedFolderOrFile(favoriteFolders[A_EventInfo])
    } else if (A_GuiEvent="ColClick") {
        path=%A_AppData%\ahk_explorer_settings\favoriteFolders.txt
        VSCodeRunner(path)
        run, %toRun%
    }
return

folderlistViewEvents1_1:
folderlistViewEvents2_1:
folderlistViewEvents1_2:
folderlistViewEvents2_2:
    whichSide:=SubStr(A_GuiControl, 0)
    num:=SubStr(A_GuiControl, 15, 1)
    whichParent:=(num=1) ? 2 : 1
    updateWinTitle()

    if (A_GuiEvent="ColClick")
    {
        if (""!=parent%whichParent%Dir%whichSide%) {
            EcurrentDir%whichSide%:=parent%whichParent%Dir%whichSide%
            renderCurrentDir()
        }
    } else if (A_GuiEvent = "DoubleClick") {
        EcurrentDir%whichSide%:=parent%whichParent%DirDirs%whichSide%[A_EventInfo]
        renderCurrentDir()
    }
return
currentDirEdit1Changed:
currentDirEdit2Changed:
    if (focused="searchCurrentDirEdit") {
        SetTimer, setTimerPleaseDoNotBlock, -0
    }
return

setTimerPleaseDoNotBlock:
    ControlGetText, currentDirEditText,, % "ahk_id " Edithwnd%whichSide%
    searchString%whichSide%:=currentDirEditText
    searchInCurrentDir()
return

glistViewEvents1:
glistViewEvents2:
    ; whichSide:=SubStr(A_GuiControl, 0)
    if (A_GuiEvent=="D") {
        selectedPaths:=getSelectedPaths()

        if (GetKeyState("Alt")) {
            FileToClipboard(selectedPaths, "cut")
        } else {
            FileToClipboard(selectedPaths)
        }

        Cursors := []
        Cursors[1] := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32515, "UPtr") ; DROPEFFECT_COPY = IDC_CROSS
        Cursors[2] := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32516, "UPtr") ; DROPEFFECT_MOVE = IDC_UPARROW
        Cursors[3] := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32648, "UPtr") ; Copy or Move = IDC_NO
        DoDragDrop(Cursors)
    }
    else if (A_GuiEvent=="F") {
        whichSide:=SubStr(A_GuiControl, 0)
        updateWinTitle()

    }
    else if (A_GuiEvent=="e") {
        whichSide:=SubStr(A_GuiControl, 0)
        focused:="flistView"
        LV_GetText(OutputVar,A_EventInfo,2)

        for k, v in stuffByName
        {
            if (v=renaming) {
                SourcePath:=filePaths[k]
                DestPath:=EcurrentDir%whichSide% "\" OutputVar
                stuffByName[k]:=OutputVar
                filePaths[k]:=DestPath
                fileExist:=FileExist(SourcePath)
                if (fileExist) {
                    if (InStr(fileExist, "D")) {
                        FileMoveDir, %SourcePath%, %DestPath%
                    } else {
                        FileMove, %SourcePath%, %DestPath%
                    }
                }
            }
        }
    } else if (A_GuiEvent=="E") {
        focused:="renaming"
        LV_GetText(OutputVar,A_EventInfo,2)
        renaming:=OutputVar
        SplitPath, OutputVar, , , OutExtension, OutNameNoExt
        if (OutNameNoExt) {
            Postmessage,0xB1, 0, % StrLen(OutNameNoExt), Edit2
        } else {
            Postmessage,0xB1, 1, % StrLen(OutExtension)+1, Edit2
        }
    } else if (A_GuiEvent = "DoubleClick")
    {
        if (!canRename)
            doubleClickedNormal(A_EventInfo)
    }
    else if (A_GuiEvent=="K") ;key pressed
    {
        whichSide:=SubStr(A_GuiControl, 0)
        ControlFocus,, % "ahk_id " hwndListview%whichSide%
        Gui, ListView, vlistView%whichSide%

        key := GetKeyName(Format("vk{:x}", A_EventInfo))
        switch (key) {

        case "Backspace":
        case "Lwin":
        case "NumpadRight":
        case "NumpadLeft":
        case "NumpadUp":
        case "NumpadDown":
        case "Alt":
        case "Control":
        case "Shift":
        case "F1":
            send, {f1}
        case "F3":
            send, {f3}
        case "F4":
            ; send, {f4}
        case "\":
        case "NumpadEnd":
        case "Numpad0":
        case "NumpadHome":
        case "NumpadPgDn":
        case "NumpadPgUp":
        case "]":
        case "NumpadDel":
            selectedNames:=getSelectedNames()

            for k, v in getSelectedNames() {
                finalStr:="""" A_AhkPath """ ""lib\fileRecycle_one.ahk"" """ EcurrentDir%whichSide% "\" v """"
                run, %finalStr%
            }
            return
        Default:
            if (StrLen(key) > 1) { ;I hope this catches something like Numlock
                return
            }

            if (focused!="searchCurrentDirEdit")
            {
                ShiftIsDown := GetKeyState("Shift")
                CtrlIsDown := GetKeyState("Ctrl")

                if (CtrlIsDown and !ShiftIsDown) {
                    if (key="c") {
                        selectedPaths:=getSelectedPaths()
                        FileToClipboard(selectedPaths)
                        SoundPlay, *-1
                    }
                    else if (key="x") {
                        selectedPaths:=getSelectedPaths()
                        FileToClipboard(selectedPaths, "cut")
                        SoundPlay, *-1
                    } else if (key="v")
                    {
                        pasteFile()

                    } else if (key="a") {
                        loop % LV_GetCount()
                        {
                            LV_Modify(A_Index, "+Select") ; select
                        }
                    } else if (key="h") {

                    }
                    return
                } else if (ShiftIsDown and !CtrlIsDown) {
                    if (key="F10") {
                        selectedNames:=getSelectedNames()
                        ShellContextMenu(EcurrentDir%whichSide%,selectedNames)
                    }
                } else if (CtrlIsDown and ShiftIsDown) {
                    if (key="x") {
                        for k, v in getSelectedNames() ;extract using 7zip, 7-zip
                        {
                            archive:=EcurrentDir%whichSide% "\" v
                            SplitPath, archive,, OutDir,, OutNameNoExt
                            SevenZip_extract(archive, OutDir "\" OutNameNoExt)
                        }
                        soundplay, *-1
                        EcurrentDir%whichSide%:=OutDir "\" OutNameNoExt
                        renderCurrentDir()
                        return
                    } else if (key="z") {
                    } else if (key="d") {
                        files:=array_ToSpacedString(getSelectedPaths())
                        runwait, "%peazipPath%" -add2archive %files%
                        soundplay, *-1
                        renderCurrentDir() ;refresh
                        return
                    } else if (key="v") {
                        if (DllCall("IsClipboardFormatAvailable", "UInt", CF_HDROP := 15)) { ; file being copied
                            if (DllCall("IsClipboardFormatAvailable", "UInt", dropEffectFormat)) {
                                if (DllCall("OpenClipboard", "Ptr", A_ScriptHwnd)) {
                                    if (data := DllCall("GetClipboardData", "UInt", dropEffectFormat, "Ptr")) {
                                        if (effect := DllCall("GlobalLock", "Ptr", data, "UInt*")) {
                                            if (effect & DROPEFFECT_COPY) {
                                                files:=StrSplit(clipboard, "`n","`r")
                                                for k, v in files {
                                                    fileExist:=FileExist(v)
                                                    if (fileExist) {
                                                        SplitPath, v , OutFileName
                                                        dest:=EcurrentDir%whichSide%
                                                        Run, TeraCopy.exe Copy "%v%" "%dest%"
                                                    }
                                                }
                                                ; renderCurrentDir()
                                                SoundPlay, *-1
                                            }
                                            ; action:="copy"
                                            else if (effect & DROPEFFECT_MOVE) {
                                                p("no move")
                                            }
                                            ; action:="move"
                                            DllCall("GlobalUnlock", "Ptr", data)
                                        }
                                    }
                                    DllCall("CloseClipboard")
                                }
                            }
                        }
                        return

                    }
                }
                if (CtrlIsDown or ShiftIsDown) {
                    ; "PowerPoint" actually triggers this ???
                    ; d(key, CtrlIsDown, ShiftIsDown) ;p, 0, 1
                    return
                }

                focused:="searchCurrentDirEdit"
                GuiControl, Focus, vcurrentDirEdit%whichSide%

                whatsAlreadyInTheEdit:=searchString%whichSide%
                actualAlreadySearchText:=SubStr(whatsAlreadyInTheEdit, 1, StrLen(whatsAlreadyInTheEdit) - StrLen(EcurrentDir%whichSide%))
                ; capital letters are not recognized
                ; so PowerPoint, doesn't work
                ; the first letter is 'o'

                ;key is actually the first letter entered, put it at the start
                GuiControl, Text, vcurrentDirEdit%whichSide%, % key actualAlreadySearchText
                ; move caret to end
                SendMessage, 0xB1, -2, -1,, % "ahk_id " Edithwnd%whichSide%
            }

        }
    }
    else if (A_GuiEvent="RightClick") {
        selectedNames:=getSelectedNames()
        ShellContextMenu(EcurrentDir%whichSide%,selectedNames)
    }
    else if (A_GuiEvent="ColClick")
    {
        whichSide:=SubStr(A_GuiControl, 0)
        Gui, ListView, % hwndListview%whichSide%

        switch (A_EventInfo) {
            case 1:
                if ("foldersFirst"==whichsort%whichSide%)
                {
                    whichsort%whichSide%:="foldersLast"
                    ;NOT IMPLEMENTED, NEVER USED lol
                } else {
                    whichsort%whichSide%:="foldersFirst"
                    ;NOT IMPLEMENTED, NEVER USED lol
                }
            case 2:
                if ("A_Z"==whichsort%whichSide%)
                {
                    whichsort%whichSide%:="Z_A"
                    sortColumn(2, "Sort")
                } else {
                    whichsort%whichSide%:="A_Z"
                    sortColumn(2, "SortDesc")
                }
            case 3:
                if ("newOld"==whichsort%whichSide%)
                {
                    whichsort%whichSide%:="oldNew"
                    renderFunctionsToSort(sortedByDate%whichSide%, true)
                } else {
                    whichsort%whichSide%:="newOld"
                    renderFunctionsToSort(sortedByDate%whichSide%)
                }
            case 5:
                if ("bigSmall"==whichsort%whichSide%)
                {
                    whichsort%whichSide%:="smallBig"
                    renderFunctionsToSort(sortedBySize%whichSide%, true)
                } else {
                    whichsort%whichSide%:="bigSmall"
                    renderFunctionsToSort(sortedBySize%whichSide%)
                }
        }
    }

return
;includes
#include <cMsgbox>
#include <WatchFolder2>
#include %A_LineFile%\..\VD.ahk\_VD.ahk
; #Include <stringSimilarity>
#Include <stringSimilarity2>
;Classes
; ======================================================================================================================
; Namespace:      LV_Colors
; Function:       Helper object and functions for ListView row and cell coloring
; Testted with:   AHK 1.1.15.04 (A32/U32/U64)
; Tested on:      Win 8.1 (x64)
; Changelog:
;     0.5.00.00/2014-08-13/just me - changed 'static mode' handling
;     0.4.01.00/2013-12-30/just me - minor bug fix
;     0.4.00.00/2013-12-30/just me - added static mode
;     0.3.00.00/2013-06-15/just me - added "Critical, 100" to avoid drawing issues
;     0.2.00.00/2013-01-12/just me - bugfixes and minor changes
;     0.1.00.00/2012-10-27/just me - initial release
; ======================================================================================================================
; CLASS LV_Colors
;
; The class provides seven public methods to register / unregister coloring for ListView controls, to set individual
; colors for rows and/or cells, to prevent/allow sorting and rezising dynamically, and to register / unregister the
; included message handler function for WM_NOTIFY -> NM_CUSTOMDRAW messages.
;
; If you want to use the included message handler you must call LV_Colors.OnMessage() once.
; Otherwise you should integrate the code within LV_Colors_WM_NOTIFY into your own notification handler.
; Without notification handling coloring won't work.
; ======================================================================================================================
Class LV_Colors {
    ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ; PRIVATE PROPERTIES ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Static MessageHandler := "LV_Colors_WM_NOTIFY"
    Static WM_NOTIFY := 0x4E
    Static SubclassProc := RegisterCallback("LV_Colors_SubclassProc")
    ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ; PUBLIC PROPERTIES  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ; Static Critical := 0
    Static Critical := 100
    ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ; META FUNCTIONS ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    __New(P*) {
        Return False ; There is no reason to instantiate this class!
    }
    ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ; PRIVATE METHODS +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    On_NM_CUSTOMDRAW(H, L) {
        Static CDDS_PREPAINT := 0x00000001
        Static CDDS_ITEMPREPAINT := 0x00010001
        Static CDDS_SUBITEMPREPAINT := 0x00030001
        Static CDRF_DODEFAULT := 0x00000000
        Static CDRF_NEWFONT := 0x00000002
        Static CDRF_NOTIFYITEMDRAW := 0x00000020
        Static CDRF_NOTIFYSUBITEMDRAW := 0x00000020
        Static CLRDEFAULT := 0xFF000000
        ; Size off NMHDR structure
        Static NMHDRSize := (2 * A_PtrSize) + 4 + (A_PtrSize - 4)
        ; Offset of dwItemSpec (NMCUSTOMDRAW)
        Static ItemSpecP := NMHDRSize + (5 * 4) + A_PtrSize + (A_PtrSize - 4)
        ; Size of NMCUSTOMDRAW structure
        Static NCDSize := NMHDRSize + (6 * 4) + (3 * A_PtrSize) + (2 * (A_PtrSize - 4))
        ; Offset of clrText (NMLVCUSTOMDRAW)
        Static ClrTxP := NCDSize
        ; Offset of clrTextBk (NMLVCUSTOMDRAW)
        Static ClrTxBkP := ClrTxP + 4
        ; Offset of iSubItem (NMLVCUSTOMDRAW)
        Static SubItemP := ClrTxBkP + 4
        ; Offset of clrFace (NMLVCUSTOMDRAW)
        Static ClrBkP := SubItemP + 8
        DrawStage := NumGet(L + NMHDRSize, 0, "UInt")
        , Row := NumGet(L + ItemSpecP, 0, "UPtr") + 1
        , Col := NumGet(L + SubItemP, 0, "Int") + 1
        If This[H].IsStatic
            Row := This.MapIndexToID(H, Row)
        ; SubItemPrepaint ------------------------------------------------------------------------------------------------
        If (DrawStage = CDDS_SUBITEMPREPAINT) {
            NumPut(This[H].CurTX, L + ClrTxP, 0, "UInt"), NumPut(This[H].CurTB, L + ClrTxBkP, 0, "UInt")
            , NumPut(This[H].CurBK, L + ClrBkP, 0, "UInt")
            ClrTx := This[H].Cells[Row][Col].T, ClrBk := This[H].Cells[Row][Col].B
            If (ClrTx <> "")
                NumPut(ClrTX, L + ClrTxP, 0, "UInt")
            If (ClrBk <> "")
                NumPut(ClrBk, L + ClrTxBkP, 0, "UInt"), NumPut(ClrBk, L + ClrBkP, 0, "UInt")
            If (Col > This[H].Cells[Row].MaxIndex()) && !This[H].HasKey(Row)
                Return CDRF_DODEFAULT
            Return CDRF_NOTIFYSUBITEMDRAW
        }
        ; ItemPrepaint ---------------------------------------------------------------------------------------------------
        If (DrawStage = CDDS_ITEMPREPAINT) {
            This[H].CurTX := This[H].TX, This[H].CurTB := This[H].TB, This[H].CurBK := This[H].BK
            ClrTx := ClrBk := ""
            If This[H].Rows.HasKey(Row)
                ClrTx := This[H].Rows[Row].T, ClrBk := This[H].Rows[Row].B
            If (ClrTx <> "")
                NumPut(ClrTx, L + ClrTxP, 0, "UInt"), This[H].CurTX := ClrTx
            If (ClrBk <> "")
                NumPut(ClrBk, L + ClrTxBkP, 0, "UInt") , NumPut(ClrBk, L + ClrBkP, 0, "UInt")
            , This[H].CurTB := ClrBk, This[H].CurBk := ClrBk
            If This[H].Cells.HasKey(Row)
                Return CDRF_NOTIFYSUBITEMDRAW
            Return CDRF_DODEFAULT
        }
        ; Prepaint -------------------------------------------------------------------------------------------------------
        If (DrawStage = CDDS_PREPAINT) {
            Return CDRF_NOTIFYITEMDRAW
        }
        ; Others ---------------------------------------------------------------------------------------------------------
        Return CDRF_DODEFAULT
    }
    ; -------------------------------------------------------------------------------------------------------------------
    MapIndexToID(HWND, Row) {
        ; LVM_MAPINDEXTOID = 0x10B4 -> http://msdn.microsoft.com/en-us/library/bb761139(v=vs.85).aspx
        SendMessage, 0x10B4, % (Row - 1), 0, , % "ahk_id " . HWND
        Return ErrorLevel
    }
    ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ; PUBLIC METHODS ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ; ===================================================================================================================
    ; Attach()        Register ListView control for coloring
    ; Parameters:     HWND        -  ListView's HWND.
    ;                 Optional ------------------------------------------------------------------------------------------
    ;                 StaticMode  -  Static color assignment, i.e. the colors will be assigned permanently to a row
    ;                                rather than to a row number.
    ;                                Values:  True / False
    ;                                Default: False
    ;                 NoSort      -  Prevent sorting by click on a header item.
    ;                                Values:  True / False
    ;                                Default: True
    ;                 NoSizing    -  Prevent resizing of columns.
    ;                                Values:  True / False
    ;                                Default: True
    ; Return Values:  True on success, otherwise false.
    ; ===================================================================================================================
    Attach(HWND, StaticMode := False, NoSort := True, NoSizing := True) {
        Static LVM_GETBKCOLOR := 0x1000
        Static LVM_GETHEADER := 0x101F
        Static LVM_GETTEXTBKCOLOR := 0x1025
        Static LVM_GETTEXTCOLOR := 0x1023
        Static LVM_SETEXTENDEDLISTVIEWSTYLE := 0x1036
        Static LVS_EX_DOUBLEBUFFER := 0x00010000
        If !DllCall("User32.dll\IsWindow", "Ptr", HWND, "UInt")
            Return False
        If This.HasKey(HWND)
            Return False
        ; Set LVS_EX_DOUBLEBUFFER style to avoid drawing issues, if it isn't set as yet.
        SendMessage, % LVM_SETEXTENDEDLISTVIEWSTYLE, % LVS_EX_DOUBLEBUFFER, % LVS_EX_DOUBLEBUFFER, , % "ahk_id " . HWND
        If (ErrorLevel = "FAIL")
            Return False
        ; Get the default colors
        SendMessage, % LVM_GETBKCOLOR, 0, 0, , % "ahk_id " . HWND
        BkClr := ErrorLevel
        SendMessage, % LVM_GETTEXTBKCOLOR, 0, 0, , % "ahk_id " . HWND
        TBClr := ErrorLevel
        SendMessage, % LVM_GETTEXTCOLOR, 0, 0, , % "ahk_id " . HWND
        TxClr := ErrorLevel
        ; Get the header control
        SendMessage, % LVM_GETHEADER, 0, 0, , % "ahk_id " . HWND
        Header := ErrorLevel
        ; Store the values in a new object
        This[HWND] := {BK: BkClr, TB: TBClr, TX: TxClr, Header: Header, IsStatic: !!StaticMode}
        If (NoSort)
            This.NoSort(HWND)
        If (NoSizing)
            This.NoSizing(HWND)
        Return True
    }
    ; ===================================================================================================================
    ; Detach()        Unregister ListView control
    ; Parameters:     HWND        -  ListView's HWND
    ; Return Value:   Always True
    ; ===================================================================================================================
    Detach(HWND) {
        ; Remove the subclass, if any
        Static LVM_GETITEMCOUNT := 0x1004
        If (This[HWND].SC)
            DllCall("Comctl32.dll\RemoveWindowSubclass", "Ptr", HWND, "Ptr", This.SubclassProc, "Ptr", HWND)
        This.Remove(HWND, "")
        WinSet, Redraw, , % "ahk_id " . HWND
        Return True
    }
    ; ===================================================================================================================
    ; Row()           Set background and/or text color for the specified row
    ; Parameters:     HWND        -  ListView's HWND
    ;                 Row         -  Row number
    ;                 Optional ------------------------------------------------------------------------------------------
    ;                 BkColor     -  Background color as RGB color integer (e.g. 0xFF0000 = red)
    ;                                Default: Empty -> default background color
    ;                 TxColor     -  Text color as RGB color integer (e.g. 0xFF0000 = red)
    ;                                Default: Empty -> default text color
    ; Return Value:   True on success, otherwise false.
    ; ===================================================================================================================
    Row(HWND, Row, BkColor := "", TxColor := "") {
        If !This.HasKey(HWND)
            Return False
        If This[HWND].IsStatic
            Row := This.MapIndexToID(HWND, Row)
        If (BkColor = "") && (TxColor = "") {
            This[HWND].Rows.Remove(Row, "")
            Return True
        }
        BkBGR := TxBGR := ""
        If BkColor Is Integer
            BkBGR := ((BkColor & 0xFF0000) >> 16) | (BkColor & 0x00FF00) | ((BkColor & 0x0000FF) << 16)
        If TxColor Is Integer
            TxBGR := ((TxColor & 0xFF0000) >> 16) | (TxColor & 0x00FF00) | ((TxColor & 0x0000FF) << 16)
        If (BkBGR = "") && (TxBGR = "")
            Return False
        If !This[HWND].HasKey("Rows")
            This[HWND].Rows := {}
        If !This[HWND].Rows.HasKey(Row)
            This[HWND].Rows[Row] := {}
        If (BkBGR <> "")
            This[HWND].Rows[Row].Insert("B", BkBGR)
        If (TxBGR <> "")
            This[HWND].Rows[Row].Insert("T", TxBGR)
        Return True
    }
    ; ===================================================================================================================
    ; Cell()          Set background and/or text color for the specified cell
    ; Parameters:     HWND        -  ListView's HWND
    ;                 Row         -  Row number
    ;                 Col         -  Column number
    ;                 Optional ------------------------------------------------------------------------------------------
    ;                 BkColor     -  Background color as RGB color integer (e.g. 0xFF0000 = red)
    ;                                Default: Empty -> default background color
    ;                 TxColor     -  Text color as RGB color integer (e.g. 0xFF0000 = red)
    ;                                Default: Empty -> default text color
    ; Return Value:   True on success, otherwise false.
    ; ===================================================================================================================
    Cell(HWND, Row, Col, BkColor := "", TxColor := "") {
        If !This.HasKey(HWND)
            Return False
        If This[HWND].IsStatic
            Row := This.MapIndexToID(HWND, Row)
        If (BkColor = "") && (TxColor = "") {
            This[HWND].Cells.Remove(Row, "")
            Return True
        }
        BkBGR := TxBGR := ""
        If BkColor Is Integer
            BkBGR := ((BkColor & 0xFF0000) >> 16) | (BkColor & 0x00FF00) | ((BkColor & 0x0000FF) << 16)
        If TxColor Is Integer
            TxBGR := ((TxColor & 0xFF0000) >> 16) | (TxColor & 0x00FF00) | ((TxColor & 0x0000FF) << 16)
        If (BkBGR = "") && (TxBGR = "")
            Return False
        If !This[HWND].HasKey("Cells")
            This[HWND].Cells := {}
        If !This[HWND].Cells.HasKey(Row)
            This[HWND].Cells[Row] := {}
        This[HWND].Cells[Row, Col] := {}
        If (BkBGR <> "")
            This[HWND].Cells[Row, Col].Insert("B", BkBGR)
        If (TxBGR <> "")
            This[HWND].Cells[Row, Col].Insert("T", TxBGR)
        Return True
    }
    ; ===================================================================================================================
    ; NoSort()        Prevent / allow sorting by click on a header item dynamically.
    ; Parameters:     HWND        -  ListView's HWND
    ;                 Optional ------------------------------------------------------------------------------------------
    ;                 Apply       -  True / False
    ;                                Default: True
    ; Return Value:   True on success, otherwise false.
    ; ===================================================================================================================
    NoSort(HWND, Apply := True) {
        Static HDM_GETITEMCOUNT := 0x1200
        If !This.HasKey(HWND)
            Return False
        If (Apply)
            This[HWND].NS := True
        Else
            This[HWND].Remove("NS")
        Return True
    }
    ; ===================================================================================================================
    ; NoSizing()      Prevent / allow resizing of columns dynamically.
    ; Parameters:     HWND        -  ListView's HWND
    ;                 Optional ------------------------------------------------------------------------------------------
    ;                 Apply       -  True / False
    ;                                Default: True
    ; Return Value:   True on success, otherwise false.
    ; ===================================================================================================================
    NoSizing(HWND, Apply := True) {
        Static OSVersion := DllCall("Kernel32.dll\GetVersion", "UChar")
        Static HDS_NOSIZING := 0x0800
        If !This.HasKey(HWND)
            Return False
        HHEADER := This[HWND].Header
        If (Apply) {
            If (OSVersion < 6) {
                If !(This[HWND].SC) {
                    DllCall("Comctl32.dll\SetWindowSubclass", "Ptr", HWND, "Ptr", This.SubclassProc, "Ptr", HWND, "Ptr", 0)
                    This[HWND].SC := True
                } Else {
                    Return True
                }
            } Else {
                Control, Style, +%HDS_NOSIZING%, , ahk_id %HHEADER%
            }
        } Else {
            If (OSVersion < 6) {
                If (This[HWND].SC) {
                    DllCall("Comctl32.dll\RemoveWindowSubclass", "Ptr", HWND, "Ptr", This.SubclassProc, "Ptr", HWND)
                    This[HWND].Remove("SC")
                } Else {
                    Return True
                }
            } Else {
                Control, Style, -%HDS_NOSIZING%, , ahk_id %HHEADER%
            }
        }
        Return True
    }
    ; ===================================================================================================================
    ; OnMessage()     Register / unregister LV_Colors message handler for WM_NOTIFY -> NM_CUSTOMDRAW messages
    ; Parameters:     Apply       -  True / False
    ;                                Default: True
    ; Return Value:   Always True
    ; ===================================================================================================================
    OnMessage(Apply := True) {
        If (Apply)
            OnMessage(This.WM_NOTIFY, This.MessageHandler)
        Else If (This.MessageHandler = OnMessage(This.WM_NOTIFY))
            OnMessage(This.WM_NOTIFY, "")
        Return True
    }
}
; ======================================================================================================================
; PRIVATE FUNCTION LV_Colors_WM_NOTIFY() - message handler for WM_NOTIFY -> NM_CUSTOMDRAW notifications
; ======================================================================================================================
LV_Colors_WM_NOTIFY(W, L) {
    Static NM_CUSTOMDRAW := -12
    Static LVN_COLUMNCLICK := -108
    Critical, % LV_Colors.Critical
    If LV_Colors.HasKey(H := NumGet(L + 0, 0, "UPtr")) {
        M := NumGet(L + (A_PtrSize * 2), 0, "Int")
        ; NM_CUSTOMDRAW --------------------------------------------------------------------------------------------------
        If (M = NM_CUSTOMDRAW)
            Return LV_Colors.On_NM_CUSTOMDRAW(H, L)
        ; LVN_COLUMNCLICK ------------------------------------------------------------------------------------------------
        If (LV_Colors[H].NS && (M = LVN_COLUMNCLICK))
            Return 0
    }
}
; ======================================================================================================================
; PRIVATE FUNCTION LV_Colors_SubclassProc() - subclass for WM_NOTIFY -> HDN_BEGINTRACK notifications (Win XP)
; ======================================================================================================================
LV_Colors_SubclassProc(H, M, W, L, S, R) {
    Static HDN_BEGINTRACKA := -306
    Static HDN_BEGINTRACKW := -326
    Static WM_NOTIFY := 0x4E
    Critical, % LV_Colors.Critical
    If (M = WM_NOTIFY) {
        ; HDN_BEGINTRACK -------------------------------------------------------------------------------------------------
        C := NumGet(L + (A_PtrSize * 2), 0, "Int")
        If (C = HDN_BEGINTRACKA) || (C = HDN_BEGINTRACKW) {
            Return True
        }
    }
Return DllCall("Comctl32.dll\DefSubclassProc", "Ptr", H, "UInt", M, "Ptr", W, "Ptr", L, "UInt")
}
; ======================================================================================================================
;start of functions start

updateWinTitle() {
    global
    ; sets WinTitle to current dir
    WinSetTitle, % thisUniqueWintitle, , % EcurrentDir%whichSide% " - ahk_explorer"
}
; focusListview() {
    ; global
    ; ControlFocus,, % "ahk_id " hwndListview%whichSide%
; }

updateDirsToWatch() {
    global dirWatched, whichSide, EcurrentDir1, EcurrentDir2, lastDir1, lastDir2

    ; what if I had 3 panes ?
    ; 1. we always want to add watch
    ; 2. we do not add watch if already watched
    ; use a map to figure out if already
    ; watched
    ; diretory -> whichSide
    if (!dirWatched.HasKey(EcurrentDir%whichSide%)) {
        dirWatched[EcurrentDir%whichSide%]:=whichSide
        startWatchFolder(whichSide, EcurrentDir%whichSide%)
    }

    ; 1. we always want to remove watch
    ; // 2. we do not remove watch if blank (this is taken care of by WatchFolder2.ahk)
    ; 3. we remove watch, and if there's another same, we add the watch back to that. so loop though every side.
    ; using the map, we only remove watch if watch is on self pane.
    if (dirWatched[lastDir%whichSide%]==whichSide) {
        dirWatched.Delete(lastDir%whichSide%)
        stopWatchFolder(lastDir%whichSide%)
        loop 2 { ;how many panes
            if (EcurrentDir%A_Index%==lastDir%whichSide%) {
                startWatchFolder(A_Index, lastDir%whichSide%)
                break
            }
        }
    }

}

normalize_Any_Path(dPath, parentDir:=false) { ;parentDir to convert relative to absolute
    if (dPath=="") { ;this is needed because _getFullPathName will transform "" into "C:\"
        return false
    }
    dPath:=RTrim(dPath," `t")
    dPath:=StrReplace(dPath, "/" , "\")
    ; path "\\" -> "\" and "\\\\\" -> "\"
    dPath:=RegExReplace(dPath, "\\{2,}" , "\")

    if (SubStr(dPath,1,5)="file:") {
        dPath:=UrlUnescape(SubStr(dPath,7))
    }

    fullPath:=_getFullPathName(dPath, parentDir)
    if (fullPath==false) {
        return false
    }

    return _fixCasingOfPath(fullPath)
}
UrlUnescape(url_) { ;found at https://www.autohotkey.com/boards/viewtopic.php?t=84825#post_content372262
    buf_size:=StrLen(url_)*2
    VarSetCapacity(buf, buf_size)
    DllCall("Shlwapi\UrlUnescape", "Str", url_, "Ptr", &buf, "UInt*", buf_size, "UInt", 0x00040000, "UInt")
    Return StrGet(&buf, "UTF-16")
}
_getFullPathName(dPath, parentDir:=false) { ;https://www.autohotkey.com/boards/viewtopic.php?t=67050#p289536
    if (SubStr(dPath,2,1)==":") {
        ;already a full path
        return dPath
    } else {
        if (parentDir) {
            return parentDir "\" dPath
        } else {
            return A_WorkingDir "\" dPath
        }
    }
    ; dPath:=RTrim(dPath,"\") "\"
    ; cc := DllCall("GetFullPathNameW", "str", dPath, "uint", 0, "ptr", 0, "ptr", 0, "uint")
    ; if (cc==0) {
        ; return false
    ; }
    ; VarSetCapacity(buf, cc*2)
    ; DllCall("GetFullPathNameW", "str", dPath, "uint", cc, "ptr", &buf, "ptr", 0, "uint")
    ; return StrGet(&buf)
}
_fixCasingOfPath(fullPath) {
    HRESULT:=DllCall("shell32\SHParseDisplayName", "Ptr", &fullPath, "Uint", 0, "Ptr*", pIDL, "Uint", 0, "Uint", 0)
    if (HRESULT) {
        return false
    }
    ; if (HRESULT==-2147024809) { ; input":"
        ; return false
    ; } else if (HRESULT!=0) {
        ; MsgBox % "_fixCasingOfPath HRESULT!=0 what error is this ?"
        ; MsgBox % Clipboard:=HRESULT
        ; -2147024894 ; input"joifjwoiejgweg"
        ; -2147024894 ; input"C:\doesnotexist"
    ; }
    VarSetCapacity(pszPath, 600) ;600 was a random number
    DllCall("shell32\SHGetPathFromIDListW", "Ptr", pIDL, "Ptr", &pszPath)
    DllCall("ole32\CoTaskMemFree", "Ptr", pIDL) ;free memory
    return StrGet(&pszPath+0)
}


imgFileToBase64DataURL(fullPath) {
    FileAttrib:=FileExist(fullPath)
    if (!FileAttrib)
        return false
    if (InStr(FileAttrib, "D"))
        return false

    ;from here on out, the file must exist
    hFile:=DllCall("CreateFileW"
    , "Str", fullPath
    , "Uint", 0x80000000 ;GENERIC_READ
    , "Uint", 0x7 ;FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE : 0x00000001 | 0x00000002 | 0x00000004
    , "Ptr", 0
    , "Uint", 3 ;OPEN_EXISTING : Opens a file or device, only if it exists.
    , "Uint", 128 ;FILE_ATTRIBUTE_NORMAL
    , "Ptr", 0
    , "Ptr")

    DllCall("GetFileSizeEx"
    , "Ptr", hFile
    , "Int64*", _FileSize)

    VarSetCapacity(fileBuffer, _FileSize)

    success:=DllCall("ReadFile"
    , "Ptr", hFile
    , "Ptr", &fileBuffer
    , "Uint", _FileSize ;ok, Int64 _FileSize was probably overkill
    , "Ptr", 0
    , "Ptr", 0)

    ;since it's base64, use ANSI:
    ; get size
    DllCall("Crypt32.dll\CryptBinaryToStringA"
    , "Ptr", &fileBuffer
    , "Uint", _FileSize ;ok, Int64 _FileSize was probably overkill
    , "Uint", 0x40000001 ; 0x40000000 | 0x00000001 : CRYPT_STRING_NOCRLF | CRYPT_STRING_BASE64
    , "Ptr", 0
    , "Uint*", pcchString)
    VarSetCapacity(base64Buffer, pcchString)
    DllCall("Crypt32.dll\CryptBinaryToStringA"
    , "Ptr", &fileBuffer
    , "Uint", _FileSize ;ok, Int64 _FileSize was probably overkill
    , "Uint", 0x40000001 ; 0x40000000 | 0x00000001 : CRYPT_STRING_NOCRLF | CRYPT_STRING_BASE64
    , "Ptr", &base64Buffer
    , "Uint*", pcchString)

    base64Str:=StrGet(&base64Buffer, "CP0") ;CP0: ANSI

    SplitPath, fullPath,,, OutExtension
    switch (OutExtension) {
        case "svg":
            OutExtension:="svg+xml"
        case "jpg":
            OutExtension:="jpeg"
    }
    return "data:image/" OutExtension ";base64," base64Str

}

Activate_Ahk_Explorer_() {
    global

    minimizeCortana()

    if WinExist(thisUniqueWintitle)
    {
        Gui, main:Default
        WinActivate % "ahk_class Shell_TrayWnd"
        WinWaitActive % "ahk_class Shell_TrayWnd"
        WinActivate % thisUniqueWintitle
        ControlFocus,, % "ahk_id " hwndListview%whichSide%

        ; WinGet, id, List,,, Program Manager
        ; finalStr:=""
        ; Loop % id
        ; {
            ; this_id := id%A_Index%
            ; WinGetClass, this_class, ahk_id %this_id%
            ; WinGetTitle, this_title, ahk_id %this_id%
            ;
            ; finalStr.=this_id "`n" this_title "`n" this_class "`n`n"
        ; }
        ; Clipboard:=finalStr

    }
    else
    {
        DetectHiddenWindows, On
        if WinExist(thisUniqueWintitle) {
            DetectHiddenWindows, off

            Gui, main:Default
            VD.MoveWindowToCurrentDesktop(thisUniqueWintitle, true)
            ControlFocus,, % "ahk_id " hwndListview%whichSide%

        } else {
            DetectHiddenWindows, off

        }
    }

}

Activate_Ahk_ExplorerToggleBetweenVSCode() {
    global thisUniqueWintitle

    minimizeCortana()

    if WinActive(thisUniqueWintitle)
    {
        winactivate, ahk_exe code.exe
    }
    else if WinExist(thisUniqueWintitle)
    {
        Gui, main:Default
        WinActivate
        ControlFocus,, % "ahk_id " hwndListview%whichSide%
    }
    else if (hiddenMatch2Exist(thisUniqueWintitle))
    {
        Gui, main:Default
        VD.MoveWindowToCurrentDesktop(thisUniqueWintitle, true)
        ControlFocus,, % "ahk_id " hwndListview%whichSide%
    }
}

hiddenMatch2Exist(wintitle) {
    DetectHiddenWindows, On
    SetTitleMatchMode, 2
    hiddenExist:=false
    if WinExist(wintitle) {
        hiddenExist:=true
    }
    SetTitleMatchMode, 1
    DetectHiddenWindows, Off
    return hiddenExist
}
VSCodeRunner(path) {
    wintitle:="vscode_runner.ahk ahk_exe AutoHotkey.exe"
    if hiddenMatch2Exist(wintitle) {
        send_stringData_Wintitle(wintitle, 1, path)
    } else {
        toRun:= """" A_AhkPath "\..\AutoHotkey.exe"" /CP65001 ""lib\vscode_runner.ahk"" """ path """"
        Run % toRun
    }
}
send_stringData_Wintitle(wintitle, num, stringToSend:="")
{
    stringToSend .= "|" num
    VarSetCapacity(message, size := StrPut(stringToSend, "UTF-16")*2, 0)
    StrPut(stringToSend, &message, "UTF-16")
    VarSetCapacity(COPYDATASTRUCT, A_PtrSize*3)
    NumPut(size, COPYDATASTRUCT, A_PtrSize, "UInt")
    NumPut(&message, COPYDATASTRUCT, A_PtrSize*2)
    DetectHiddenWindows, On
    SetTitleMatchMode, 2
    SendMessage, WM_COPYDATA := 0x4A,, &COPYDATASTRUCT,, % wintitle
    SetTitleMatchMode, 1
    DetectHiddenWindows, Off
}

minimizeCortana()
{
    If (WinActive("ahk_exe SearchApp.exe") || WinActive("ahk_exe SearchHost.exe")) ;wintitle = "Search" ;SearchApp:Win10, SearchHost:Win11
    {
        ; esc only works when you're IN search.
        ; ctrl down + esc will minimize when in # but not search
        ; alt down instead of ctrl down will minimize it even when Win is down
        send, {alt down}{esc}{alt up}
        return true
    }
}

keyboardFocusPane(whichSide) {
    global BGColorOfSelectedPane

    otherSide:=whichSide == 1 ? 2 : 1
    Gui, ListView, % hwndListview%whichSide%
    ControlFocus,, % "ahk_id " hwndListview%whichSide%
    GuiControl, % "+Background" BGColorOfSelectedPane, % hwndListview%whichSide%
    GuiControl, % "+BackgroundWhite", % hwndListview%otherSide%
}

SevenZip_extract(archive, outputDirName:=false) {
    if (outputDirName==false) {
        outputDirName:=SevenZip_GetDefault_outputDirName(archive)
    }
    if (FileExist(outputDirName)) {
        return false
    }

    RunWait, % "lib\7-Zip-Zstandard\7z x """ archive """ -o""" outputDirName """ -spe",,Hide
    ; RunWait, % "cmd /k "" lib\7-Zip-Zstandard\7z x """ archive """ -o""" outputDirName """ -spe """
}

SevenZip_GetDefault_outputDirName(archive) {
    SplitPath, archive,, OutDir,, OutNameNoExt
    outputDirName:=OutDir "\" OutNameNoExt
    return outputDirName
}

getTextWidth(text, fontSize, fontName)
{
    global vDummy_getTextWidth
    bakDefaultGui:=A_DefaultGui
    Gui,Fake:Default
    Gui,Fake:Font, % "s" fontSize, % fontName
    Gui,Fake:Add,Text, -Wrap vvDummy_getTextWidth,% text
    GuiControlGet,Pos_OutputVar,Fake:Pos,vDummy_getTextWidth
    Gui,Fake:Destroy
    Gui % bakDefaultGui ":Default"
    return Pos_OutputVarW
}

listview_getPosOfRow(hwndListview, rowZeroIndexed, Byref row_x, Byref row_y) { ; just me -> https://www.autohotkey.com/board/topic/86490-click-listview-row/#entry550767
    VarSetCapacity(RECT, 16)
    SendMessage, 0x100E, % rowZeroIndexed, % &RECT,, % "ahk_id " hwndListview ; LVM_GETITEMRECT

    row_x:=NumGet(RECT, 0, "Short")
    row_y:=NumGet(RECT, 4, "Short")
}

sortArrByKey(arr, key, reverse:=false) {
    str:=""
    for k,v in arr {
        str.=v[key] "+" k "|"
    }
    length:=arr.Length()
    firstValue:=arr[1][key]
    if firstValue is number
    {
        sortType := "N"
    }
    Sort, str, % "D|" sortType (reverse ? "" : "R")
    finalAr:=[]
    finalAr.SetCapacity(length)
    barPos:=1

    loop %length% {
        plusPos:=InStr(str, "+",, barPos)
        barPos:=InStr(str, "|",, plusPos)

        num:=SubStr(str, plusPos + 1, barPos - plusPos - 1)
        finalAr.Push(arr[num])
    }
return finalAr
}

hashFiles(algorithm, algoDisplayName:=false)
{
    global EcurrentDir1, EcurrentDir2, whichSide
    finalStr=
    for notUsed, name in getSelectedNames() {
        hash:=getHash(algorithm, EcurrentDir%whichSide% "\" name)
        StringUpper, uppercaseHash, hash
        finalStr.=uppercaseHash "`n"
    }
    if (finalStr) {
        StringTrimRight, finalStr, finalStr, 1 ;remove the last "`n" from the end
        clipboard:=finalStr
        if (algoDisplayName!=false) {
            finalStr:=algoDisplayName ":`n" finalStr
        }
        cMsgbox(finalStr)
    } else {
        p("couldn't get hash")
    }
}

getHash(algorithm, Apath)
{
    FileGetAttrib, fileAttrib, %Apath%
    if (InStr(fileAttrib, "D")) {
        return "can't hash Directory"
    } else {
        cmdOutput:=RunCmd("certutil -hashfile """ Apath """ " algorithm)
        return StrSplit(cmdOutput, "`n", "`r")[2]
    }
}

generateRandomUniqueName(Apath, byref isDir:="")
{
    inputFileExist:=fileExist(Apath)
    if (inputFileExist) {
        if (InStr(inputFileExist, "D"))
            isDir:=true
        SplitPath, Apath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
        loop {
            if (isDir) {
                tryPath:=OutDir "\" OutNameNoExt "_" randomName(6)
            } else {
                tryPath:=OutDir "\" OutNameNoExt "_" randomName(6) "." OutExtension
            }
            if (!FileExist(tryPath)) {
                return tryPath
            }
        }
    } else {
        p("input path does not exist")
    }

}
randomName(length)
{
    chars:=[".", "_", "-", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

    charsLength:=chars.Length()

    loop % length
    {
        Random, randInt , 1, charsLength
        strng.=chars[randInt]
    }
return strng
}

loadSettings()
{
    global
    FileRead, settingsTxt, %A_AppData%\ahk_explorer_settings\settings.txt
    settingsArr:=StrSplit(settingsTxt, "`n", "`r")
    peazipPath:=settingsArr[1]
    vscodePath:=settingsArr[2]
    BGColorOfSelectedPane:=settingsArr[3]
    Ahk2ExePath:=settingsArr[4]
    spekPath:=settingsArr[5]
}

removeFromSizes(byref name, byref whichSide)
{
    for k, obj in sortedSizes%whichSide% {
        if (obj["name"]=name) {
            sortedSizes%whichSide%.Remove(k)
            break
        }
    }
}
addToSizes(byref name, byref size, byref whichSide)
{
    sortedSizes%whichSide%.Push({size:size,name:name})
    sortedSizes%whichSide%:=sortArrByKey(sortedSizes%whichSide%,"size")
    ; sortedSizes%whichSide%:=sortArrByKey(sortedSizes%whichSide%,"size",true)

    sortedBySize%whichSide%:=[]
    for k, v in sortedSizes%whichSide% {
        sortedBySize%whichSide%.Push(v["name"])
    }
}
sortSizes()
{
    global

    sortedSizes%whichSide%:=[]
    for name, obj in stuffByName%whichSide% {
        sortedSizes%whichSide%.Push({size:obj["size"],name:name})
    }

    sortedSizes%whichSide%:=sortArrByKey(sortedSizes%whichSide%,"size")
    ; sortedSizes%whichSide%:=sortArrByKey(sortedSizes%whichSide%,"size",true)
    sortedBySize%whichSide%:=[]
    for k, v in sortedSizes%whichSide% {
        sortedBySize%whichSide%.Push(v["name"])
    }

}

bothSameDir(whichSide)
{
    global
    otherSide:=(whichSide=1) ? 2 : 1
    if (EcurrentDir%whichSide%=EcurrentDir%otherSide%)
        return otherSide
return false
}

startWatchFolder(whichSide, AcurrentDir)
{
    WatchFolder.Add(AcurrentDir, "Watch" whichSide, 0, 3) ;files and folders
}
stopWatchFolder(dirToStopWatching)
{
    WatchFolder.Remove(dirToStopWatching)
}
Watch1(Folder, Changes) {
    For Each, Change In Changes {
        WatchN(1,Change)
    }
}
Watch2(Folder, Changes) {
    For Each, Change In Changes {
        WatchN(2,Change)
    }
}
WatchN(whichSide, Change)
{
    global EcurrentDir1,EcurrentDir2,vlistView1,vlistView2
    otherSide:=bothSameDir(whichSide)
    GuiControl, -Redraw, vlistView%whichSide%
    if (otherSide)
        GuiControl, -Redraw, vlistView%otherSide%

    switch (Change.Action) {
    case 1:
        fileAdded(whichSide, Change.Name)
    case 2:
        fileDeleted(whichSide, Change.Name)
        if (otherSide) {
            fileDeleted(otherSide, Change.Name)
        }
    case 4: ;rename
        Name:=Change.Name
        OldName:=Change.OldName
        SplitPath, Name, OutFileNameNew, OutDirNew
        SplitPath, OldName, OutFileNameOld, OutDirOld
        if (OutDirNew=EcurrentDir%whichSide%) { ;renamed
            fileRenamed(whichSide, OutFileNameOld, OutFileNameNew)
            if (otherSide) {
                fileRenamed(otherSide, OutFileNameOld, OutFileNameNew)
            }
        } else if (OutDirOld=EcurrentDir%otherSide%) { ;moved from other Side
            fileAdded(whichSide, Name)
            fileDeleted(otherSide, OldName)
        } else { ;moved

            fileAdded(whichSide, Name)
            if (otherSide) {
                fileAdded(otherSide, Name)
            }
        }
    }
    GuiControl, +Redraw, vlistView%whichSide%
    if (otherSide)
        GuiControl, +Redraw, vlistView%otherSide%

}
fileRenamed(whichSide, Byref renameFrom,Byref renameInto)
{
    global
    Gui, main:Default
    Gui, ListView, vlistView%whichSide%
    FileGetSize, outputSize, % EcurrentDir%whichSide% "\" renameInto
    obj:=stuffByName%whichSide%[renameFrom]
    stuffByName%whichSide%[renameInto]:=stuffByName%whichSide%[renameFrom]
    stuffByName%whichSide%.Delete(renameFrom)
    stuffByName%whichSide%[renameInto]["size"]:=outputSize

    ;rename in sortedByDate
    for k, v in sortedByDate%whichSide% {
        if (v=renameFrom) {
            sortedByDate%whichSide%[k]:=renameInto
            break
        }
    }

    removeFromSizes(renameFrom, whichSide)
    addToSizes(renameInto,outputSize, whichSide)

    rowNums:=LV_GetCount()
    loop % rowNums {
        LV_GetText(OutputVar,A_Index,2)
        if (OutputVar=renameFrom) {
            calculateStuff(,outputSize,OutputVar,A_Index)

            LV_Modify(A_Index,"Icon" getIconNum(EcurrentDir%whichSide% "\" renameInto), ,renameInto,,,formattedBytes,bytes)

            break
        }
    }
}
fileAdded(whichSide, Byref path) {
    global
    Gui, main:Default
    Gui, ListView, vlistView%whichSide%
    SplitPath, path, OutFileName
    sortWithAr%whichSide%:=[]
    FileGetSize, outputSize, %path%
    FileGetAttrib, OutputAttri , %path%

    stuffByName%whichSide%[OutFileName]:={date:A_Now,attri:OutputAttri,size:outputSize}

    sortedByDate%whichSide%.InsertAt(1,OutFileName)

    addToSizes(OutFileName,outputSize,whichSide)

    whereToAddFile(whichSide, OutFileName, A_Now,outputSize)

    if (bothSameDir(whichSide)) {
        stuffByName%otherSide%[OutFileName]:=stuffByName%whichSide%[OutFileName]
        sortedBySize%otherSide%:=sortedBySize%whichSide%.Clone()
        sortedByDate%otherSide%:=sortedByDate%whichSide%.Clone()
        whereToAddFile(otherSide, OutFileName, A_Now,outputSize)
    }

}
fileDeleted(whichSide, path)
{
    global
    Gui, main:Default
    Gui, ListView, vlistView%whichSide%
    SplitPath, path, OutFileName
    GuiControl, -Redraw, vlistView%whichSide%

    rowNums:=LV_GetCount()
    loop % rowNums {
        LV_GetText(OutputVar,A_Index,2)
        if (OutputVar=OutFileName) {

            LV_Delete(A_Index)
            if !LV_GetNext(1) {
                if (A_Index=rowNums and A_Index>1) {
                    LV_Modify(A_Index-1, "+Select +Focus Vis") ; select
                }
                else
                    LV_Modify(A_Index, "+Select +Focus Vis") ; select
            }
            ; GuiControl, +Redraw, vlistView%whichSide%
            obj:=stuffByName%whichSide%[OutFileName]

            ;remove name from sortedByDate
            for k, v in sortedByDate%whichSide% {
                if (v=OutFileName) {
                    sortedByDate%whichSide%.Remove(k)
                    break
                }
            }

            removeFromSizes(OutFileName,whichSide)

            stuffByName%whichSide%.Delete(OutFileName)

            break
        }
    }
}

whereToAddFile(byref whichSide, byref OutFileName,byref date,byref size) {
    global
    Gui, main:Default
    Gui, ListView, vlistView%whichSide%
    insertNum:=0

    if (whichsort%whichSide%="newOld") {
        if (focused="searchCurrentDirEdit" or focused="listViewInSearch") {
            if (SubStr(searchString%whichSide%, 1, 1)!=".") {
                counter:=0
                objectToSort:=[]
                for k,v in sortedByDate%whichSide% {
                    if (counter>maxRows)
                        break
                    SplitPath, v,,,, OutNameNoExt

                    pos:=InStr(OutNameNoExt, searchString%whichSide%)
                    if (pos) {
                        counter++
                        objectToSort.Push({name:v,pos:pos})
                    }
                }
                sortedObj:=sortArrByKey(objectToSort,"pos",true)

                for k,v in sortedObj {
                    name:=v["name"]
                    if (name=OutFileName) {
                        insertNum:=k
                    }
                }
            } else {
                searchFoldersOnly:=(searchString%whichSide%=".") ? true : false
                if (searchFoldersOnly) {
                    counter:=0
                    for k,v in sortedByDate%whichSide% {
                        if (v=OutFileName) {
                            if (counter>maxRows)
                                break
                            SplitPath, v,,, OutExtension
                            if (!OutExtension) {
                                insertNum:=k
                            }
                        }
                    }
                } else {
                    searchStringBak%whichSide%:=SubStr(searchString%whichSide%, 2)
                    counter:=0
                    objectToSort:=[]
                    for k,v in sortedByDate%whichSide% {
                        if (counter>maxRows)
                            break
                        SplitPath, v,,, OutExtension
                        pos:=InStr(OutExtension, searchStringBak%whichSide%)
                        if (pos) {
                            counter++
                            objectToSort.Push({name:v,pos:pos})
                        }
                    }
                    sortedObj:=sortArrByKey(objectToSort,"pos",true)
                    for k,v in sortedObj {
                        name:=v["name"]
                        if (name=OutFileName) {
                            insertNum:=k
                        }
                    }
                }

            }
        } else {
            insertNum:=1
        }
    } else if (whichsort%whichSide%="oldNew") {
        rowNums:=LV_GetCount()
        insertNum:=rowNums+1
    } else if (whichsort%whichSide%="bigSmall") {
        for k, v in sortedBySize%whichSide% {
            if (k>maxRows)
                break
            if (v=OutFileName) {
                insertNum:=k
            }
        }
    } else if (whichsort%whichSide%="smallBig") {
        lengthAddedOne:=sortedBySize%whichSide%.Length()+1
        for k in sortedBySize%whichSide% {
            v:=sortedBySize%whichSide%[lengthAddedOne-k]
            if (k>maxRows)
                break
            if (v=OutFileName) {
                insertNum:=k
            }
        }
    }

    if (insertNum) {
        insertRow(whichSide, OutFileName, insertNum, date,size)
    }
}

insertRow(byref whichSide, byref OutFileName,byref row,byref date,byref size)
{
    global

    Gui, main:Default
    Gui, ListView, vlistView%whichSide%
    calculateStuff(date,size,OutFileName,row)
    GuiControl, -Redraw, vlistView%whichSide%
    LV_Insert(row,"Icon" getIconNum(EcurrentDir%whichSide% "\" OutFileName),,OutFileName,var1,var2,formattedBytes,bytes)
    LV_Colors.Cell(hwndListview%whichSide%,row,3,color)

    GuiControl, +Redraw, vlistView%whichSide%
}

pasteFile()
{
    global
    ; action:=false
    if (DllCall("IsClipboardFormatAvailable", "UInt", CF_HDROP := 15)) { ; file being copied
        if (DllCall("IsClipboardFormatAvailable", "UInt", dropEffectFormat)) {
            if (DllCall("OpenClipboard", "Ptr", A_ScriptHwnd)) {
                if (data := DllCall("GetClipboardData", "UInt", dropEffectFormat, "Ptr")) {
                    if (effect := DllCall("GlobalLock", "Ptr", data, "UInt*")) {
                        ; action:="copy"
                        if (effect & DROPEFFECT_COPY) {
                            files:=StrSplit(clipboard, "`n","`r")
                            for k, v in files {
                                fileExist:=FileExist(v)
                                if (fileExist) {
                                    SplitPath, v , OutFileName
                                    if (InStr(fileExist, "D")) {
                                        FileCopyDir, %v%, % EcurrentDir%whichSide% "\" OutFileName
                                    } else {
                                        FileCopy, %v%, % EcurrentDir%whichSide%
                                    }
                                    if (ErrorLevel) {
                                        p("couldn't copy file " v)
                                        break
                                    }
                                }
                            }
                            SoundPlay, *-1
                        }
                        ; action:="move"
                        else if (effect & DROPEFFECT_MOVE) {
                            files:=StrSplit(clipboard, "`n","`r")
                            if (files.Length()) {
                                for k, v in files {
                                    fileExist:=FileExist(v)
                                    if (fileExist) {
                                        SplitPath, v , OutFileName
                                        if (InStr(fileExist, "D")) {
                                            FileMoveDir, %v%, % EcurrentDir%whichSide% "\" OutFileName
                                        } else {
                                            FileMove, %v%, % EcurrentDir%whichSide%
                                        }
                                        if (ErrorLevel) {
                                            p("couldn't move file " v)
                                            break
                                        }
                                    }
                                }

                                SoundPlay, *-1
                            }

                        }
                        DllCall("GlobalUnlock", "Ptr", data)
                    }
                }
                DllCall("CloseClipboard")
            }
        }
    }

}

paddedNumber(number, howManyChars)
{
    VarSetCapacity(ZeroPaddedNumber, 20) ; Ensure the variable is large enough to accept the new string.
    DllCall("wsprintf", "Str", ZeroPaddedNumber, "Str", "%0" howManyChars "d", "Int", number, "Cdecl") ; Requires the Cdecl calling convention.
return ZeroPaddedNumber
}

setWhichSideFromDir(dir)
{
    global
    if (EcurrentDir1=dir) {
        whichSide:=1
    } else if (EcurrentDir2=dir) {
        whichSide:=2
    }
}

getMultiRenameNames()
{
    global
    Gui, multiRenameGui:Default
    gui, submit, nohide

    startingNums:=StrSplit(multiRenameStartingNums, ",")
    asteriskLength:=StrSplit(multiRenameTheName, "*").Length()
    previewNames:=[]
    for k, v in namesToMultiRename {
        nameInstance:=multiRenameTheName

        continueChar:=true
        charIndex:=1

        length:=StrLen(nameInstance)
        lessGreaters:=[]
        asterisksAndQmarks:=[]
        while (charIndex<=length) {
            char:=SubStr(nameInstance, charIndex, 1)

            if (char="*") {
                asterisksAndQmarks.Push("*")
            } else if (char="?") {

                questionMarkCounter:=0
                while (char="?") {
                    questionMarkCounter++
                    charIndex++
                    char:=SubStr(nameInstance, charIndex, 1)
                }
                asterisksAndQmarks.Push(string_Multiply("?",questionMarkCounter))
                continue
            } else if (char="<") {
                savedIndex:=charIndex
                while (char!=">") {
                    charIndex++
                    char:=SubStr(nameInstance, charIndex, 1)
                }
                subLen:=charIndex - savedIndex + 1
                asterisksAndQmarks.Push(SubStr(nameInstance, savedIndex, subLen))
                lessGreaters.Insert(1, [savedIndex,subLen])
                continue
            }
            charIndex++
        }
        for key, value in lessGreaters {
            nameInstance:=SubStr(nameInstance, 1, value[1]-1) SubStr(nameInstance, value[1] + value[2])
        }

        SplitPath, v,,, OutExtension, OutNameNoExt
        nameInstance:=StrReplace(nameInstance, "|namenoext", OutNameNoExt)
        nameInstance:=StrReplace(nameInstance, "|name", v)
        nameInstance:=StrReplace(nameInstance, "|ext", OutExtension)

        fileExist:=fileExist(multiRenameDir "\" v)
        if (InStr(fileExist, "D" )) {
            nameInstance:=StrReplace(nameInstance, "|Dext" , "")
            nameInstance:=StrReplace(nameInstance, "|.Dext" , "")
        } else {
            nameInstance:=StrReplace(nameInstance, "|Dext" , OutExtension)
            nameInstance:=StrReplace(nameInstance, "|.Dext" , "." OutExtension)
        }

        for key, value in asterisksAndQmarks {
            num:=(startingNums[key]) ? startingNums[key] : 1
            actualNum:=num+k-1
            if (InStr(value, "?" )) {
                actualNum:=paddedNumber(actualNum, StrLen(value))
            } else if (InStr(value, "<" )) {
                inside:=SubStr(value, 2, StrLen(value)-2)
                nameInstance:=StrReplace(nameInstance, inside, "",, num)
                if (num<0) {
                    p("oof")
                }
                continue
            }
            nameInstance:=StrReplace(nameInstance, value , actualNum,, 1)
        }

        previewNames.Push(nameInstance)

    }
return previewNames
}

calculateStuff(ByRef date:="", ByRef size:="", ByRef name:="", Byref k:="") {
    global
    if (calculateDates and date!="") {
        now:=A_Now
        var1Num := now
        var2 := date
        EnvSub, var1Num, %var2%, Minutes
        var1:=var1Num "’"
        color=0xFF0000 ;red
        if (Abs(var1Num)>525599) {
            var1Num := now
            EnvSub, var1Num, %var2%, Days
            var1Num:=Floor(var1Num/365.25) ;the average days in a month
            var1:=var1Num " y"
            color=0x808080 ;grey ; pink
        }
        else if (Abs(var1Num)>86399) {
            var1Num := now
            EnvSub, var1Num, %var2%, Days
            var1Num:=Floor(var1Num/30.44) ;the average days in a month
            var1:=var1Num " m"
            color=0x00FFFF ;AQUA
        }
        else if (Abs(var1Num)>1439) {
            var1Num := now
            EnvSub, var1Num, %var2%, Days
            var1:=var1Num " d"
            color=0x00FF00 ;lime green
        } else if (Abs(var1Num)>59) {
            var1Num := now
            EnvSub, var1Num, %var2%, Hours
            var1:=var1Num " h"
            color=0xFFFF00 ;yellow
        }
    }
    if (calculatefileSizes and size!="") {
        bytes:=""
        formattedBytes:=""

        bytes:=size

        if (bytes!="")
            formattedBytes:=autoByteFormat(bytes)
    }
}
applySizes() {
    global
    if (namesForSizes%whichSide%.Length()) {
        namesStr:="""" EcurrentDir%whichSide% """"
        for k, v in namesForSizes%whichSide% {
            namesStr.=" """ v """"
        }
        Process, Close, %PID_getFolderSizes%
        Run, "%A_AhkPath%" "lib\getFolderSizes.ahk" %namesStr%,,,PID_getFolderSizes
    } else {
        Process, Close, %PID_getFolderSizes%
        sortSizes()
        canSortBySize%whichSide%:=true
    }
}

renderFunctionsToSort(ByRef objectToSort, reverse:=false)
{
    global
    Gui, main:Default
    Gui, ListView, vlistView%whichSide%

    GuiControl,Text,vcurrentDirEdit%whichSide%, % EcurrentDir%whichSide%
    searchString%whichSide%:=""

    GuiControl, -Redraw, vlistView%whichSide%
    LV_Delete()
    length:=objectToSort.Length()
    if (reverse) {
        startPos:=length
        inc:=-1
        reverseSort:=true
    }
    else {
        startPos:=1
        inc:=1
        reverseSort:=false
    }
    namesForSizes%whichSide%:=[]
    rowsForSizes%whichSide%:=[]

    if (length<=maxRows) {
        rowsToLoop:=length
    } else {
        rowsToLoop:=maxRows
        if (toFocus) {
            loop % length {
                if (toFocus=objectToSort[A_Index]) {
                    if (length - A_Index<maxRows - 1) {
                        startPos:=length - maxRows + 1
                        if (startPos<1)
                            startPos:=1
                    }
                    else {
                        startPos:=A_Index
                    }
                }
            }
        }
    }
    k:=startPos
    currentDirCache:=EcurrentDir%whichSide% "\"
    loop % rowsToLoop {
        name:=objectToSort[k]
        v:=stuffByName%whichSide%[name]

        if (name=toFocus)
        {
            rowToFocus:=A_Index
        }
        calculateStuff(v["date"],v["size"],name,A_Index)
        LV_Add("Icon" getIconNum(currentDirCache name),,name,var1,var2,formattedBytes,bytes)
        LV_Colors.Cell(hwndListview%whichSide%,A_Index,3,color)

        k+=inc
    }
    if (toFocus)
    {
        LV_Modify(rowToFocus, "+Select +Focus Vis")
    } else {
        LV_Modify(1, "+Select +Focus")
    }
    toFocus:=false
    GuiControl, +Redraw, vlistView%whichSide%
}

openInAhkExplorer(pathArgument)
{
    global

    cmdFileExist:=fileExist(pathArgument)
    if (cmdFileExist) {
        if (InStr(cmdFileExist, "D")) {
            EcurrentDir%whichSide%:=pathArgument
        } else {
            SplitPath, pathArgument, OutFileName, OutDir
            EcurrentDir%whichSide%:=OutDir
            toFocus:=OutFileName
        }
    }
    else {
        p("the folder or file you are trying to open doesn't exist`nyou were trying to open: pathArgument=`n" pathArgument)
        clipboard:=pathArgument
        cmdFileExist:=fileExist(pathArgument)
        p(cmdFileExist " pathArgument was copied to clip" )
    }
    renderCurrentDir()

    ; timerFunc:=ObjBindMethod(VD, "MoveWindowToCurrentDesktop", thisUniqueWintitle, true)
    SetTimer Activate_Ahk_Explorer_, -0 ;SetTimer IS NEEDED SOMEHOW, you can't just call a function

}

receivedFolderSize(string) {
    global

    if (rowsForSizes%whichSide%.Length()) {
        Gui, main:Default
        ar:=StrSplit(string,"|")

        whichListView_bak:=A_DefaultListView
        Gui, ListView, vlistView%whichSide%
        LV_Modify(rowsForSizes%whichSide%[1],,,,,,ar[2],ar[3])
        Gui, ListView, %whichListView_bak%

        rowsForSizes%whichSide%.RemoveAt(1)
    }
    stuffByName%whichSide%[ar[1]]["size"]:=ar[3]
}

WM_COPYDATA_READ(wp, lp) {
    global
    data := StrGet(NumGet(lp + A_PtrSize*2), "UTF-16")
    RegExMatch(data, "s)(.*)\|(\d+)", match)

    if (match2==1) {
        openInAhkExplorer(match1)
    } else if (match2==2) {
        ; p(match1)
        receivedFolderSize(match1)
    } else if (match2==3) {
        sortSizes()
        canSortBySize%whichSide%:=true
    } else if (match2==4) {
        gosub, selectPanel%match1%
    } else if (match2==5) {
        gosub, copySelectedPaths
    } else if (match2==6) {
        SetTimer, Activate_Ahk_ExplorerToggleBetweenVSCode, -0 ;SetTimer IS NEEDED SOMEHOW, you can't just call a function
    } else {
        p("something went wrong")
    }
}

submitAndRenderDir()
{
    global
    Gui, main:Default
    Gui, Submit, NoHide

    StringUpper, OutputVar,% SubStr(vcurrentDirEdit%whichSide%,1,1)
    EcurrentDir%whichSide%:=OutputVar SubStr(vcurrentDirEdit%whichSide%,2)
    renderCurrentDir()
}

Bin(x){
    while x
        r:=1&x r,x>>=1
return r
}
compareTwoStrings2(para_string1,para_string2) {
    ;Sørensen-Dice coefficient
    savedBatchLines := A_BatchLines
    SetBatchLines, -1

    vCount := 0
    oArray := {}
oArray := {base:{__Get:Func("Abs").Bind(0)}} ;make default key value 0 instead of a blank string
Loop, % vCount1 := StrLen(para_string1) - 1
    oArray["z" SubStr(para_string1, A_Index, 2)]++
Loop, % vCount2 := StrLen(para_string2) - 1
if (oArray["z" SubStr(para_string2, A_Index, 2)] > 0) {
    oArray["z" SubStr(para_string2, A_Index, 2)]--
    vCount++
}
vSDC := Round((2 * vCount) / (vCount1 + vCount2),2)
; if (!vSDC || vSDC < 0.005) { ;round to 0 if less than 0.005
; return 0
; }
if (vSDC = 1) {
return 1
}
SetBatchLines, % savedBatchLines
return vSDC
}

compareTwoStrings(para_string1,para_string2)
{
    ;Sørensen-Dice coefficient
    savedBatchLines := A_BatchLines
    SetBatchLines, -1

    vCount := 0
    oArray := {}
oArray := {base:{__Get:Func("Abs").Bind(0)}} ;make default key value 0 instead of a blank string
Loop, % vCount1 := StrLen(para_string1)
    ; Loop, % vCount1 := StrLen(para_string1) - 1
oArray["z" SubStr(para_string1, A_Index, 1)]++
; oArray["z" SubStr(para_string1, A_Index, 2)]++
Loop, % vCount2 := StrLen(para_string2)
    ; Loop, % vCount2 := StrLen(para_string2) - 1
; p(oArray)
if (oArray["z" SubStr(para_string2, A_Index, 1)] > 0) {
    ; if (oArray["z" SubStr(para_string2, A_Index, 2)] > 0) {
    oArray["z" SubStr(para_string2, A_Index, 1)]--
    ; oArray["z" SubStr(para_string2, A_Index, 2)]--
    vCount++
}
; p(vCount)
vSDC := (vCount) / (vCount2)
; vSDC := (2 * vCount) / (vCount1 + vCount2)
; vSDC := Round((2 * vCount) / (vCount1 + vCount2),2)
; if (!vSDC || vSDC < 0.005) { ;round to 0 if less than 0.005
; return 0
; }
if (vSDC = 1) {
return 1
}
SetBatchLines, % savedBatchLines
return vSDC
}

autoMegaByteFormat(size, decimalPlaces = 2)
{
    static sizes :=["GB", "TB"]

    sizeIndex := 0

    while (size >= 1024)
    {
        sizeIndex++
        size /= 1024.0

        if (sizeIndex = sizes.Length())
            break
    }

return (sizeIndex = 0) ? size " MB"
: round(size, decimalPlaces) . " " . sizes[sizeIndex]
}

autoByteFormat(size, decimalPlaces = 2)
{
    static sizes :=["KB", "MB", "GB", "TB"]

    sizeIndex := 0

    while (size >= 1024)
    {
        sizeIndex++
        size /= 1024.0

        if (sizeIndex = sizes.Length())
            break
    }

return (sizeIndex = 0) ? size " B"
: round(size, decimalPlaces) . " " . sizes[sizeIndex]
}

sortColumn(column, sortMethod)
{
    static columnsToSort:=[1,2,4,6] ;I don't even know what this does, but these will be set to NoSort

    for k, v in columnsToSort {
        if (v!=column) {
            LV_ModifyCol(v, "NoSort")
        }
    }
    LV_ModifyCol(column, sortMethod)
}

getSelectedNames()
{
    global
    gui, main:default
    Gui, ListView, vlistView%whichSide%
    index:=""
    selectedNames:=[]
    loop {
        index:=LV_GetNext(index)
        if (!index)
            break
        LV_GetText(OutputVar,index,2)
        selectedNames.Push(OutputVar)

    }
return selectedNames
}

getSelectedPaths()
{
    global whichSIde, EcurrentDir1, EcurrentDir2
    dCurrentDir:=RTrim(EcurrentDir%whichSide%, "\") "\"
    selectedPaths:=[]
    for k, v in getSelectedNames() {
        selectedPaths.Push(dCurrentDir v)
    }
    return selectedPaths
}

doubleClickedNormal(ByRef index)
{
    global
    gui, main:default
    ControlFocus,, % "ahk_id " hwndListview%whichSide%
    Gui, ListView, vlistView%whichSide%

    LV_GetText(filename,index,2)
    path:=EcurrentDir%whichSide% "\" filename
    doubleClickedFolderOrFile(path)
}

doubleClickedFolderOrFile(ByRef path)
{
    global
    fileExist:=FileExist(path)
    if (fileExist) {
        if (InStr(fileExist, "D"))
        {
            EcurrentDir%whichSide%:=path
            renderCurrentDir()
        }
        else {
            path:=path
            Run, "%path%", % EcurrentDir%whichSide%
        }
    }
    ControlFocus,, % "ahk_id " hwndListview%whichSide%
}

stopSearching()
{
    global
    Gui, main:Default
    ControlFocus,, % "ahk_id " hwndListview%whichSide%
    focused=flistView
    GuiControl,Text,currentDirEdit, % EcurrentDir%whichSide%
    searchString%whichSide%=
    renderCurrentDir()
}

; hex(num) {
;   return Format("0x{1:X}", num)
; }
HandleMessage( p_w, p_l, p_m, p_hw )
{
    global
    local control
    ; return
    ; p(p_w)

    ; switch p_w {
    ; case 0x1000003:
        ; focusedControl:="Edit"
    ; case 0x2000003:
        ; focusedControl:="Listview"
    ; case 0x3000003:
        ; EditOnInput()
    ; case 0x4000003:
    ; 0x3000007
    ; 0x300000B
    ; default:
        ; tooltip % hex(p_w) ", " hex(p_l) ", " hex(p_m) ", " hex(p_hw)
    ; }
    ; return

    if (!ignoreOut) {
        if (p_w=0x1000007) {
            ; p(p_l)

            whichSide:=1
            updateWinTitle()
            if (focused="flistView") ; if listView for instance
            {
                focused:="changePath"
            } else if (focused="listViewInSearch") {
                focused:="searchCurrentDirEdit"
            }
        }
        else if (p_w=0x100000B) {

            whichSide:=2
            updateWinTitle()
            if (focused="flistView") ; if listView for instance
            {
                focused:="changePath"
            } else if (focused="listViewInSearch") {
                focused:="searchCurrentDirEdit"
            }
        }

        ;   16777222
        else if ( p_w & 0x2000000 )
        {
            if (p_w=0x2000007) {

                whichSide:=1
                updateWinTitle()
            }
            else if (p_w=0x200000B) {

                whichSide:=2
                updateWinTitle()
            }

            if (((p_w >> 16) & 0x200) and not ((p_w >> 16) & 0x100))
                ; if (If ((p_w >> 16) & 0x200) and not ((p_w >> 16) & 0x100))
            {
                if ( p_l = Edithwnd%whichSide% )
                {
                    if (focused="searchCurrentDirEdit")
                    {
                        focused=listViewInSearch
                    }
                    else if (focused="changePath") {
                        ;// 'path edit' lost focus
                        submitAndRenderDir()
                    }
                    else
                    {
                        ; Gui, Submit, NoHide
                        ; currentDir:=currentDirEdit
                        ;
                    }
                } else if ( p_l = RenameHwnd ) {
                    if (!fromButton)
                        gosub, renameFileLabel
                }
            }
        }
    }

}
return

initIconStuff() {
    global ImageListID1, ImageListID2, IconCacheObj, IconNopeExtension, sfi

    LV_Colors.OnMessage()
    ImageListID%A_Index% := IL_Create(50)
    ; Create an ImageList so that the ListView can display some icons:
    ImageListID1 := IL_Create(10)
    ImageListID2 := IL_Create(10, 10, true) ; A list of large icons to go with the small ones.
    loop 2 {
        Gui, ListView, vlistView%A_Index%
        LV_Colors.Attach(hwndListview%A_Index%, 1, 0)

        LV_ModifyCol(1,20)
        LV_ModifyCol(2,300)
        LV_ModifyCol(3,"50 Right")
        LV_ModifyCol(5,"80 Right")

        LV_ModifyCol(2, "Logical")
        LV_ModifyCol(6,"Integer")

        LV_ModifyCol(4,0) ; hides 3rd row
        LV_ModifyCol(6,0) ; hides 3rd row

        ; Attach the ImageLists to the ListView so that it can later display the icons:
        LV_SetImageList(ImageListID1)
        LV_SetImageList(ImageListID2)
    }
    IconNopeExtension:={EXE:1,ICO:1,ANI:1,CUR:1,LNK:1} ;.exe, .lnk
    VarSetCapacity(sfi, A_PtrSize + 8 + (A_IsUnicode ? 680 : 340))
    IconCacheObj:={}

    _getIconFromFullPath("C:\Windows") ;this is a folder that's always there
    ;the first will always be 1

}

getIconNum(fullPath) {
    global IconCacheObj, IconNopeExtension
    global stuffByName, whichSide
    ; Build a unique extension ID to avoid characters that are illegal in variable names,
    ; such as dashes. This unique ID method also performs better because finding an item
    ; in the array does not require search-loop.

    SplitPath, fullPath,OutFileName,, FileExt ; Get the file's extension.
    if (InStr(stuffByName%whichSide%[OutFileName].attri, "D", true)) {
        return 1 ;the first will always be 1, set at _getIconFromFullPath("C:\Windows")
    } else {
        if (IconNopeExtension[FileExt])
        {
            ExtID := FileExt ; Special ID as a placeholder.
            IconNumber := false ; Flag it as not found so that these types can each have a unique icon.
        }
        else ; Some other extension/file-type, so calculate its unique ID.
        {
            ExtID := 0 ; Initialize to handle extensions that are shorter than others.
            Loop 7 ; Limit the extension to 7 characters so that it fits in a 64-bit value.
            {
            ExtChar := SubStr(FileExt, A_Index, 1)
            if not ExtChar ; No more characters.
                break
            ; Derive a Unique ID by assigning a different bit position to each character:
            ExtID := ExtID | (Asc(ExtChar) << (8 * (A_Index - 1)))
            }
            ; Check if this file extension already has an icon in the ImageLists. If it does,
            ; several calls can be avoided and loading performance is greatly improved,
            ; especially for a folder containing hundreds of files:
            IconNumber := IconCacheObj[ExtID]
        }

        if (!IconNumber) ; There is not yet any icon for this extension, so load it.
        {
            IconNumber:=_getIconFromFullPath(fullPath)
            ; Cache the icon to save memory and improve loading performance:
            IconCacheObj[ExtID] := IconNumber
        }

        return IconNumber
    }



}
_getIconFromFullPath(fullPath) {
    global ImageListID1, ImageListID2, sfi
    ; Get the high-quality small-icon associated with this file extension:
    if not DllCall("Shell32\SHGetFileInfo" . (A_IsUnicode ? "W":"A"), "Str", fullPath
    , "UInt", 0, "Ptr", &sfi, "UInt", sfi_size, "UInt", 0x101) ; 0x101 is SHGFI_ICON+SHGFI_SMALLICON
        IconNumber := 9999999 ; Set it out of bounds to display a blank icon.
    else ; Icon successfully loaded.
    {
        ; Extract the hIcon member from the structure:
        hIcon := NumGet(sfi, 0)
        ; Add the HICON directly to the small-icon and large-icon lists.
        ; Below uses +1 to convert the returned index from zero-based to one-based:
        IconNumber := DllCall("ImageList_ReplaceIcon", "Ptr", ImageListID1, "Int", -1, "Ptr", hIcon) + 1
        DllCall("ImageList_ReplaceIcon", "Ptr", ImageListID2, "Int", -1, "Ptr", hIcon)
        ; Now that it's been copied into the ImageLists, the original should be destroyed:
        DllCall("DestroyIcon", "Ptr", hIcon)
    }

    return IconNumber
}

searchInCurrentDir() {
    global

    theSearchString:=searchString%whichSide%
    if (theSearchString=="") {
        return
    }
    searching:=true
    Gui, main:Default
    Gui, ListView, vlistView%whichSide%

    ignoreOut:=true
    objectToSort:=[]

    currentDirCache:=EcurrentDir%whichSide% "\"
    GuiControl, -Redraw, vlistView%whichSide%
    LV_Delete()
    if (SubStr(theSearchString, 1, 1)!=".") {
        ;doesn't start with .

        if (StrLen(theSearchString) < 3) {
            ;howMuchOf_searchString_isFound() doesn't work well with strLen<3
            ; when < 3, we sort by found position of Needle
            counter:=0
            objectToSort:=[]

            for k,v in sortedByDate%whichSide% {
                if (counter>maxRows)
                    break
                attri:=stuffByName%whichSide%[v]["attri"]
                if InStr(attri, "D") {
                    pos:=InStr(v, theSearchString)
                } else {
                    SplitPath, v,,,, OutNameNoExt
                    pos:=InStr(OutNameNoExt, theSearchString)
                }

                if (pos) {
                    counter++
                    objectToSort.Push({name:v,pos:pos})
                }
            }
            sortedObj:=sortArrByKey(objectToSort,"pos",true)

        } else {
            counter:=0
            objectToSort:=[]

            this_SortedByDate_Pairs:=sortedByDate_Pairs%whichSide%

            StringUpper, theSearchString, theSearchString
            searchString_pairs := wordLetterPairs(theSearchString), reverse_searchString_pairs:=reverse_wordLetterPairs(theSearchString)
            searchString_pairs_Len := searchString_pairs.Length() + 1
            union := searchString_pairs.Length()
            for k,v in sortedByDate%whichSide% {
                if (counter>maxRows)
                    break

;function start
                hayStack_pairs := this_SortedByDate_Pairs[k]

                similarity_value := 0

                startingI := 1
                lastFound_hayStack_pairsIdx:=0
                ; lastFound_hayStack_pairsIdx:=false
                outer:
                for k2, pair1 in hayStack_pairs {
                    i:=startingI
                    while (i < searchString_pairs_Len) {
                        if (pair1 == searchString_pairs[i]) {

                            howManyPoints:=1

                        } else if (pair1 == reverse_searchString_pairs[i]) {

                            howManyPoints:=0.5

                        } else {
                            i++
                            continue
                        }

                        ; if (lastFound_hayStack_pairsIdx) {
                            similarity_value+=howManyPoints/(k2 - lastFound_hayStack_pairsIdx)
                        ; } else {
                            ; similarity_value++
                        ; }

                        startingI:=i + 1
                        if (startingI==searchString_pairs_Len) {
                            break outer
                        }

                        lastFound_hayStack_pairsIdx := k2
                        break
                    }
                }
                similarity_value/=union
;function end
                if (similarity_value > 0.35) {
                    counter++
                    objectToSort.Push({name:v,similarity_value:similarity_value})
                }
            }
            ; d(objectToSort)
            sortedObj:=sortArrByKey(objectToSort,"similarity_value")
            ; d(sortedObj)

        }

        ; loop % Min(maxRows, sortedObj.Count()) {
        for k, v in sortedObj {
            name:=v["name"]
            obj:=stuffByName%whichSide%[name]
            calculateStuff(obj["date"],obj["size"],name,k)

            LV_Add("Icon" getIconNum(currentDirCache name),,name,var1,var2,formattedBytes,bytes)
            LV_Colors.Cell(hwndListview%whichSide%,k,3,color)
        }


    } else {
        searchFoldersOnly:=(theSearchString=".") ? true : false
        if (searchFoldersOnly) {
            ; . only
            counter:=0
            for k,name in sortedByDate%whichSide% {
                if (counter>maxRows)
                    break
                SplitPath, name,,, OutExtension
                if (!OutExtension) {
                    obj:=stuffByName%whichSide%[name]

                    calculateStuff(obj["date"],obj["size"],name,k)

                    LV_Add("Icon" getIconNum(currentDirCache name),,name,var1,var2,formattedBytes,bytes)
                    LV_Colors.Cell(hwndListview%whichSide%,k,3,color)
                }
            }
        } else {
            ; .ext
            searchStringBak%whichSide%:=SubStr(theSearchString, 2)
            counter:=0
            objectToSort:=[]
            for k,v in sortedByDate%whichSide% {
                if (counter>maxRows)
                    break
                SplitPath, v,,, OutExtension
                pos:=InStr(OutExtension, searchStringBak%whichSide%)
                if (pos) {
                    counter++
                    objectToSort.Push({name:v,pos:pos})
                }
            }
            sortedObj:=sortArrByKey(objectToSort,"pos",true)
            for k,v in sortedObj {
                name:=v["name"]
                obj:=stuffByName%whichSide%[name]

                calculateStuff(obj["date"],obj["size"],name,k)

                LV_Add("Icon" getIconNum(currentDirCache name),,name,var1,var2,formattedBytes,bytes)
                LV_Colors.Cell(hwndListview%whichSide%,k,3,color)
            }
        }

    }

    ; loop % LV_GetCount() - 1 {
        ; LV_Modify(A_Index+1, "-Select -Focus") ; select
    ; }
    LV_Modify(1, "+Select +Focus Vis") ; select

    GuiControl, +Redraw, vlistView%whichSide%

    searching:=false
    ignoreOut:=false
}

minusEverythingAfterPoint(index)
{
    global rowBak

    indexBak:=index+1
    loop % rowBak.Length() - index {
        if (rowBak[indexBak]!=0)
            rowBak[indexBak]--
        indexBak++
    }
}

addEverythingAfterPoint(index) {
    global rowBak

    indexBak:=index+1
    loop % rowBak.Length() - index {
        if (rowBak[indexBak]!=0)
            rowBak[indexBak]++
        indexBak++
    }
}

getinsertPoint(index)
{
    global rowBak
    index--
    while (rowBak[index]=0) {
        index--
    }

    if (index<1)
        return 1

return rowBak[index]+1

}

renderCurrentDir() {
    global dirHistoryArr, whichSide, EcurrentDir1, EcurrentDir2, lastDir1, lastDir2
    if (_render_Current_Dir()) {
        if (lastDir%whichSide%!=EcurrentDir%whichSide% ) {
            updateDirsToWatch()
            dirHistoryArr[whichSide].Push(lastDir%whichSide%)
        }
        lastDir%whichSide%:=EcurrentDir%whichSide%
    }
}
_render_Current_Dir()
{
    global
    local ansiPath, bothSameDir,i,k,v,y,drive,freeSpace,text,totalSpace,OutputVar
    ; global EcurrentDir1, EcurrentDir2, whichSide

    breakIfNotValid:
    loop 1 {

        dPath:=EcurrentDir%whichSide%
        dPath:=normalize_Any_Path(dPath, lastDir%whichSide%)
        if (dPath==false) {
            break breakIfNotValid
        }
        if (!InStr(fileExist(dPath),"D")) {
            ;it's a valid file, not a directory
            ;do parent dir of that file
            SplitPath % dPath, OutFileName, OutDir
            toFocus:=OutFileName
            EcurrentDir%whichSide%:=OutDir
            renderCurrentDir()
            return false
        }
        EcurrentDir%whichSide%:=dPath

        Gui, main:Default
        Gui, ListView, vlistView%whichSide%

        focused=flistView

        filePaths:=[]
        rowBak:=[]
        ; dates:=[]
        sortableDates:=[]
        sizes:=[]
        sortableSizes:=[]
        ; dateColors:=[]
        ; filesWithNoExt:=[]

        unsorted%whichSide%:=[]
        sortedByDate%whichSide%:=[]
        sortedBySize%whichSide%:=[]
        canSortBySize%whichSide%:=false
        stuffByName%whichSide%:={}
        arrSortedByDate:=[]
        arrSortedBySize:=[]
        ; sortedSizes%whichSide%:=[]
        Loop, Files, % EcurrentDir%whichSide% "\*", DF
        {
            stuffByName%whichSide%[A_LoopFileName]:={date:A_LoopFileTimeModified,attri:A_LoopFileAttrib,size:A_LoopFileSize}

            arrSortedByDate.Push({date:A_LoopFileTimeModified,name:A_LoopFileName})

            arrSortedBySize.Push({size:A_LoopFileSize,name:A_LoopFileName})
        }
        arrSortedBySize:=sortArrByKey(arrSortedBySize,"size")
        for unused, v in arrSortedBySize {
            sortedBySize%whichSide%.Push(v["name"])
        }

        arrSortedByDate:=sortArrByKey(arrSortedByDate,"date")
        for k, v in arrSortedByDate {
            sortedByDate%whichSide%.Push(v["name"])
        }

        firstSizes%whichSide%:=true
        whichsort%whichSide%:="newOld"
        oldNew%whichSide%:=false

        renderFunctionsToSort(sortedByDate%whichSide%)

        Gui, ListView, folderlistView2_%whichSide%
        GuiControl, -Redraw, folderlistView2_%whichSide%
        LV_Delete()
        parent1DirDirs%whichSide%:=[]
        SplitPath, EcurrentDir%whichSide%, , parent1Dir%whichSide%
        SplitPath, parent1Dir%whichSide%, Out2DirName%whichSide% , parent2Dir%whichSide%,,,OutDrive2%whichSide%
        SplitPath, parent2Dir%whichSide%, Out3DirName%whichSide%, parent3Dir%whichSide%,,,OutDrive3%whichSide%
        updateWinTitle()

        if (parent1Dir%whichSide%!=EcurrentDir%whichSide%) {
            if (!Out2DirName%whichSide%)
                Out2DirName%whichSide%:=OutDrive2%whichSide%
            LV_ModifyCol(1,"NoSort", Out2DirName%whichSide%)
            Loop, Files, % parent1Dir%whichSide% "\*", D
            {
                if (A_LoopFileLongPath!=EcurrentDir%whichSide%) {
                    LV_Add(, A_LoopFileName)
                    parent1DirDirs%whichSide%.Push(A_LoopFileLongPath)
                } else {
                    toSelect:=(A_Index=1) ? 1 : A_Index-1
                }
            }
            Gui, ListView, folderlistView2_%whichSide% ;just in case
            LV_Modify(toSelect, "+Select +Focus Vis") ; select
        } else
        {
            LV_ModifyCol(1,"NoSort", "")
        }
        GuiControl, +Redraw, folderlistView2_%whichSide%

        Gui, ListView, folderlistView1_%whichSide%
        GuiControl, -Redraw, folderlistView1_%whichSide%
        LV_Delete()
        parent2DirDirs%whichSide%:=[]
        if (parent2Dir%whichSide%!=parent1Dir%whichSide%) {
            if (!Out3DirName%whichSide%)
                Out3DirName%whichSide%:=OutDrive3%whichSide%
            LV_ModifyCol(1,"NoSort", Out3DirName%whichSide%)
            Loop, Files, % parent2Dir%whichSide% "\*", D
            {
                if (A_LoopFileLongPath!=parent1Dir%whichSide%) {
                    LV_Add(, A_LoopFileName)
                    parent2DirDirs%whichSide%.Push(A_LoopFileLongPath)
                } else {
                    toSelect:=(A_Index=1) ? 1 : A_Index-1
                }
            }
            Gui, ListView, folderlistView1_%whichSide% ;just in case
            LV_Modify(toSelect, "+Select +Focus Vis") ; select
        }
        else
        {
            LV_ModifyCol(1,"NoSort", "")
        }
        GuiControl, +Redraw, folderlistView1_%whichSide%

        DriveGet, OutputVar, List
        drives:=StrSplit(OutputVar,"")
        length:=drives.Length()

        for i, drive in drives {
            y:=40*(i-1)
            DriveGet, totalSpace, Capacity, %drive%:
            DriveSpaceFree, freeSpace, %drive%:

            text:=drive ":\ " Round(100-100*freeSpace/totalSpace, 2) "%`n" autoMegaByteFormat(freeSpace) "/" autoMegaByteFormat(totalSpace)
            if (i>numberOfDrives) {
                gui, add, button,h40 y%y% w%favoritesListViewWidth% vDrive%i% x0 Left ggChangeDrive, % text
            }
            else {
                GuiControl, Show, Drive%i%
                GuiControl, Text, Drive%i%, % text
            }
        }

        loop % numberOfDrives {
            if (A_Index>length) {
                GuiControl, Hide, Drive%A_Index%
            }
        }

        if (length>numberOfDrives)
            numberOfDrives:=length

        ;precomputing
        sortedByDate_Pairs%whichSide%:=[]
        sortedByDate_Arr%whichSide%:=[]

        this_SortedByDate_Pairs:=sortedByDate_Pairs%whichSide%
        this_stuffByName:=stuffByName%whichSide%

        for k,v in sortedByDate%whichSide% {
            attri:=this_stuffByName[v]["attri"]
            if InStr(attri, "D") {
                nameNoExt:=v
            } else {
                SplitPath, v,,,, nameNoExt
            }
            StringUpper, nameNoExt, nameNoExt

            this_SortedByDate_Pairs.push(wordLetterPairs(nameNoExt))
        }
        return true ;did not break breakIfNotValid
    }

    ;so here is after broke breakIfNotValid

    ;revert your path edit
    EcurrentDir%whichSide%:=lastDir%whichSide%
    GuiControl, Text, vcurrentDirEdit%whichSide%, % EcurrentDir%whichSide%

    if (focused!="changePath") {
        return renderCurrentDir()
    }
    return false ;false because broke breakIfNotValid
}

findNextDirNameNumberIteration(pathWithAsterisk)
{
    SplitPath, pathWithAsterisk,, OutDir,,OutNameNoExt
    asteriskPos:=InStr(OutNameNoExt, "*")
    left:=SubStr(OutNameNoExt, 1, asteriskPos-1)
    right:=SubStr(OutNameNoExt, asteriskPos+1)

    pathToCheck:=OutDir "\" left right
    incrementNumber:=2
    while (FileExist(pathToCheck)) {
        pathToCheck:=OutDir "\" left incrementNumber right
        incrementNumber++
    }
    return pathToCheck
}

    ShellContextMenu(folderPath, files, win_hwnd = 0 )
    {
        if ( !folderPath )
            return
        if !win_hwnd
        {
            Gui,SHELL_CONTEXT:New, +hwndwin_hwnd
            Gui,Show
        }

        If sPath Is Not Integer
            DllCall("shell32\SHParseDisplayName", "Wstr", folderPath, "Ptr", 0, "Ptr*", pidl, "Uint", 0, "Uint", 0)
        else
            DllCall("shell32\SHGetFolderLocation", "Ptr", 0, "int", folderPath, "Ptr", 0, "Uint", 0, "Ptr*", pidl)
        DllCall("shell32\SHBindToObject","Ptr",0,"Ptr",pidl,"Ptr",0,"Ptr",GUID4String(IID_IShellFolder,"{000214E6-0000-0000-C000-000000000046}"),"Ptr*",pIShellFolder)

        length:=files.Length()
        VarSetCapacity(apidl, length * A_PtrSize, 0)
        for k, v in files {
            ;IShellFolder:ParseDisplayName
            DllCall(VTable(pIShellFolder,3),"Ptr", pIShellFolder,"Ptr",win_hwnd,"Ptr",0,"Wstr",v,"Uint*",0,"Ptr*",tmpPIDL,"Uint*",0)
            NumPut(tmpPIDL, apidl, (k - 1)*A_PtrSize, "Ptr")
        }
        ;IShellFolder->GetUIObjectOf
        DllCall(VTable(pIShellFolder,10),"Ptr",pIShellFolder,"Ptr",win_hwnd,"Uint",length,"Ptr",&apidl,"Ptr",GUID4String(IID_IContextMenu,"{000214E4-0000-0000-C000-000000000046}"),"UINT*",0,"Ptr*",pIContextMenu)

        ObjRelease(pIShellFolder)
        CoTaskMemFree(pidl)

        hMenu := DllCall("CreatePopupMenu")
        ;IContextMenu->QueryContextMenu
        ;http://msdn.microsoft.com/en-us/library/bb776097%28v=VS.85%29.aspx
        DllCall(VTable(pIContextMenu, 3), "Ptr", pIContextMenu, "Ptr", hMenu, "Uint", 0, "Uint", 3, "Uint", 0x7FFF, "Uint", 0x100) ;CMF_EXTENDEDVERBS
        ; p(hMenu)
        ComObjError(0)
        global pIContextMenu2 := ComObjQuery(pIContextMenu, IID_IContextMenu2:="{000214F4-0000-0000-C000-000000000046}")
        global pIContextMenu3 := ComObjQuery(pIContextMenu, IID_IContextMenu3:="{BCFCE0A0-EC17-11D0-8D10-00A0C90F2719}")
        e := A_LastError ;GetLastError()
        ComObjError(1)
        if (e != 0)
            goTo, StopContextMenu
        Global WPOld:= DllCall("SetWindowLongPtr", "Ptr", win_hwnd, "int",-4, "Ptr",RegisterCallback("WindowProc"),"UPtr")
        DllCall("GetCursorPos", "int64*", pt)
        ; DllCall("InsertMenu", "Ptr", hMenu, "Uint", 0, "Uint", 0x0400|0x800, "Ptr", 2, "Ptr", 0)
        ; DllCall("InsertMenu", "Ptr", hMenu, "Uint", 0, "Uint", 0x0400|0x002, "Ptr", 1, "Ptr", &sPath)
        idn := DllCall("TrackPopupMenuEx", "Ptr", hMenu, "Uint", 0x0100|0x0001, "int", pt << 32 >> 32, "int", pt >> 32, "Ptr", win_hwnd, "Uint", 0)
        ; p(idn)
        ; return
        /*
        typedef struct _CMINVOKECOMMANDINFOEX {
            DWORD   cbSize;          0
            DWORD   fMask;           4
            HWND    hwnd;            8
            LPCSTR  lpVerb;          8+A_PtrSize
            LPCSTR  lpParameters;    8+2*A_PtrSize
            LPCSTR  lpDirectory;     8+3*A_PtrSize
            int     nShow;           8+4*A_PtrSize
            DWORD   dwHotKey;        12+4*A_PtrSize
            HANDLE  hIcon;           16+4*A_PtrSize
            LPCSTR  lpTitle;         16+5*A_PtrSize
            LPCWSTR lpVerbW;         16+6*A_PtrSize
            LPCWSTR lpParametersW;   16+7*A_PtrSize
            LPCWSTR lpDirectoryW;    16+8*A_PtrSize
            LPCWSTR lpTitleW;        16+9*A_PtrSize
            POINT   ptInvoke;        16+10*A_PtrSize
        } CMINVOKECOMMANDINFOEX, *LPCMINVOKECOMMANDINFOEX;
        http://msdn.microsoft.com/en-us/library/bb773217%28v=VS.85%29.aspx
        */
        struct_size := 16+11*A_PtrSize
        VarSetCapacity(pici,struct_size,0)
        NumPut(struct_size,pici,0,"Uint") ;cbSize
        NumPut(0x4000|0x20000000|0x00100000,pici,4,"Uint") ;fMask
        NumPut(win_hwnd,pici,8,"UPtr") ;hwnd
        NumPut(1,pici,8+4*A_PtrSize,"Uint") ;nShow
        NumPut(idn-3,pici,8+A_PtrSize,"UPtr") ;lpVerb
        NumPut(idn-3,pici,16+6*A_PtrSize,"UPtr") ;lpVerbW
        NumPut(pt,pici,16+10*A_PtrSize,"Uptr") ;ptInvoke

        DllCall(VTable(pIContextMenu, 4), "Ptr", pIContextMenu, "Ptr", &pici) ; InvokeCommand

        DllCall("GlobalFree", "Ptr", DllCall("SetWindowLongPtr", "Ptr", win_hwnd, "int", -4, "Ptr", WPOld,"UPtr"))
        DllCall("DestroyMenu", "Ptr", hMenu)
        StopContextMenu:
            ObjRelease(pIContextMenu3)
            ObjRelease(pIContextMenu2)
            ObjRelease(pIContextMenu)
            pIContextMenu2:=pIContextMenu3:=WPOld:=0
            Gui,SHELL_CONTEXT:Destroy
        return idn
    }
    WindowProc(hWnd, nMsg, wParam, lParam)
    {
        Global pIContextMenu2, pIContextMenu3, WPOld
        If pIContextMenu3
        { ;IContextMenu3->HandleMenuMsg2
            If !DllCall(VTable(pIContextMenu3, 7), "Ptr", pIContextMenu3, "Uint", nMsg, "Ptr", wParam, "Ptr", lParam, "Ptr*", lResult)
                Return lResult
        }
        Else If pIContextMenu2
        { ;IContextMenu2->HandleMenuMsg
            If !DllCall(VTable(pIContextMenu2, 6), "Ptr", pIContextMenu2, "Uint", nMsg, "Ptr", wParam, "Ptr", lParam)
                Return 0
        }
        Return DllCall("user32.dll\CallWindowProcW", "Ptr", WPOld, "Ptr", hWnd, "Uint", nMsg, "Ptr", wParam, "Ptr", lParam)
    }
    VTable(ppv, idx)
    {
        Return NumGet(NumGet(1*ppv)+A_PtrSize*idx)
    }

    other_vtable(ptr, n) {
        return NumGet(NumGet(ptr+0), n*A_PtrSize)
    }

    GUID4String(ByRef CLSID, String)
    {
        VarSetCapacity(CLSID, 16,0)
        return DllCall("ole32\CLSIDFromString", "wstr", String, "Ptr", &CLSID) >= 0 ? &CLSID : ""
    }
    Guid_FromStr(sGuid, ByRef VarOrAddress)
    {
        if IsByRef(VarOrAddress) && (VarSetCapacity(VarOrAddress) < 16)
            VarSetCapacity(VarOrAddress, 16) ; adjust capacity
        pGuid := IsByRef(VarOrAddress) ? &VarOrAddress : VarOrAddress
        if ( DllCall("ole32\CLSIDFromString", "WStr", sGuid, "Ptr", pGuid) < 0 )
            throw Exception("Invalid GUID", -1, sGuid)
        return pGuid ; return address of GUID struct
    }
    Guid_ToStr(ByRef VarOrAddress)
    {
        pGuid := IsByRef(VarOrAddress) ? &VarOrAddress : VarOrAddress
        VarSetCapacity(sGuid, 78) ; (38 + 1) * 2
        if !DllCall("ole32\StringFromGUID2", "Ptr", pGuid, "Ptr", &sGuid, "Int", 39)
            throw Exception("Invalid GUID", -1, Format("<at {1:p}>", pGuid))
        return StrGet(&sGuid, "UTF-16")
    }
    CoTaskMemFree(pv)
    {
        Return DllCall("ole32\CoTaskMemFree", "Ptr", pv)
    }
    FileToClipboard(PathToCopy,Method="copy")
    {
        FileCount:=0
        PathLength:=0
        FileCount:=PathToCopy.Length()
        ; Count files and total string length

        for k, v in PathToCopy {
            PathLength+=StrLen(v)
        }
        ; Loop,Parse,PathToCopy,`n,`r
        ; {
        ; PathLength+=StrLen(A_LoopField)
        ; }

        pid:=DllCall("GetCurrentProcessId","uint")
        hwnd:=WinExist("ahk_pid " . pid)
        ; 0x42 = GMEM_MOVEABLE(0x2) | GMEM_ZEROINIT(0x40)
        hPath := DllCall("GlobalAlloc","uint",0x42,"uint",20 + (PathLength + FileCount + 1) * 2,"UPtr")
        pPath := DllCall("GlobalLock","UPtr",hPath)
        NumPut(20,pPath+0),pPath += 16 ; DROPFILES.pFiles = offset of file list
        NumPut(1,pPath+0),pPath += 4 ; fWide = 0 -->ANSI,fWide = 1 -->Unicode
        Offset:=0
        for k, v in PathToCopy {
            offset += StrPut(v,pPath+offset,StrLen(v)+1,"UTF-16") * 2
        }
        ; Loop,Parse,PathToCopy,`n,`r ; Rows are delimited by linefeeds (`r`n).
        ; offset += StrPut(A_LoopField,pPath+offset,StrLen(A_LoopField)+1,"UTF-16") * 2
        ;
        DllCall("GlobalUnlock","UPtr",hPath)
        DllCall("OpenClipboard","UPtr",hwnd)
        DllCall("EmptyClipboard")
        DllCall("SetClipboardData","uint",0xF,"UPtr",hPath) ; 0xF = CF_HDROP

        ; Write Preferred DropEffect structure to clipboard to switch between copy/cut operations
        ; 0x42 = GMEM_MOVEABLE(0x2) | GMEM_ZEROINIT(0x40)
        mem := DllCall("GlobalAlloc","uint",0x42,"uint",4,"UPtr")
        str := DllCall("GlobalLock","UPtr",mem)

        if (Method="copy")
            DllCall("RtlFillMemory","UPtr",str,"uint",1,"UChar",0x05)
        else if (Method="cut")
            DllCall("RtlFillMemory","UPtr",str,"uint",1,"UChar",0x02)
        else
        {
            DllCall("CloseClipboard")
        return
    }

    DllCall("GlobalUnlock","UPtr",mem)

    cfFormat := DllCall("RegisterClipboardFormat","Str","Preferred DropEffect")
    DllCall("SetClipboardData","uint",cfFormat,"UPtr",mem)
    DllCall("CloseClipboard")
    return
}

;end of functions
;hotkeys

#if ;global hotkeys

#e::Activate_Ahk_ExplorerToggleBetweenVSCode()

#if WinActive(thisUniqueWintitle)

!d::
fullPath:=getSelectedPaths()[1]
Clipboard:=imgFileToBase64DataURL(fullPath)
return

^e::
; revealFileInExplorer(EcurrentDir%whichSide%, getSelectedNames())
path:=getSelectedPaths()[1]
if (path) {
    Run, % "explorer.exe /select,""" path """"
} else {
    Run, % "explorer.exe """ EcurrentDir%whichSide% """"
}
return
; rotate JPEG images in a lossless way
!r::
; https://www.etcwiki.org/wiki/IrfanView_Command_Line_Options
; i_view64.exe "c:\test.jpg" /jpg_rotate=(
;   Rotate 270:5,
;   optimize:1,
;   Set EXIF date:1,
;   Keep current date:0,
;   Set DPI:0,
;   DPI value:0,
;   Marker option: Keep all (0), Clean all (1), Custom (2):0,
;   Custom markers values (can be combined (add values)):0
;   )
path:=getSelectedPaths()[1]
if (path) {
    SplitPath, path,, OutDir, OutExtension, OutNameNoExt
    if (OutExtension="jpg" or OutExtension="jpeg") {
        Run % """lib\irfanview\i_view64.exe"" """ path """ /jpg_rotate=(5,1,1,0,0,0,0,0) /cmdexit"
    } else {
        p("need to select .jpg or .jpeg")
    }
}
return

; extract embedded images from PDF
; https://superuser.com/questions/49099/how-do-i-save-an-image-pdf-file-as-an-image#answer-107773
; I like to think pdf -> jpg
^j::
path:=getSelectedPaths()[1]
if (path) {
    SplitPath, path,, OutDir, OutExtension, OutNameNoExt
    if (OutExtension="pdf") {
        Run % """lib\pdfimages.exe"" -j -list """ path """ """ OutDir "\" OutNameNoExt """"
    } else {
        p("need to select .pdf")
    }
}
return
; compress jpeg
!j::
for unused, fullPath in getSelectedPaths() {

    SplitPath % fullPath, , OutDir, , OutNameNoExt
    convertTo:=OutDir "\irfanViewCompressed\" OutNameNoExt ".jpg"

    toRun:="""lib\irfanview\i_view64.exe"" """ fullPath """ /jpgq=50 /convert=""" convertTo """ /cmdexit"
    ; MsgBox % Clipboard:=toRun
    RunWait % toRun
}
return
; darkenWithIrfanView
^+j::
for unused, fullPath in getSelectedPaths() {

    SplitPath % fullPath, OutFileName, OutDir
    convertTo:=OutDir "\irfanViewConverted\" OutFileName

    toRun:="""lib\irfanview\i_view64.exe"" """ fullPath """ /contrast=-30 /gamma=0.30 /convert=""" convertTo """"
    ; MsgBox % Clipboard:=toRun
    RunWait % toRun
}
return
; $ img2pdf img1.png img2.jpg -o out.pdf
; $ pip install img2pdf
^+!j::
toRun:="""img2pdf"""
selectedPaths:=getSelectedPaths()
for unused, fullPath in selectedPaths {
    toRun .= " """ fullPath """"
}
SplitPath % selectedPaths[1], ,OutDir , ,OutNameNoExt
if (SubStr(OutNameNoExt, -4) == "-0000") {
    OutNameNoExt:=SubStr(OutNameNoExt, 1, -5)
}
toRun.=" -o """ OutDir "\" OutNameNoExt ".pdf"""
; MsgBox % Clipboard:=toRun
RunWait % toRun
return

#d::
    if (focused="changePath") {
        focused:="flistView"
        GuiControl, Focus, vlistView%whichSide%
        ComObjCreate("Shell.Application").ToggleDesktop()
        submitAndRenderDir()
    } else {
        ComObjCreate("Shell.Application").ToggleDesktop()
    }
return
$^+left::
    if (focused="changePath" or focused="searchCurrentDirEdit") {
        send, ^+{left}
        return
    }
    gui, main:default
    whichSide:=1
    updateWinTitle()

    keyboardFocusPane(1)

    EcurrentDir1:=EcurrentDir2
    renderCurrentDir()
return
$^+right::
    if (focused="changePath") {
        send, ^+{right}
        return
    }
    gui, main:default
    whichSide:=2
    updateWinTitle()

    keyboardFocusPane(2)

    EcurrentDir2:=EcurrentDir1
    renderCurrentDir()
return
left:: ;always uses keyboard hook
^left::
    if (focused="changePath" or focused="searchCurrentDirEdit") {
        thisHotkey:=StrReplace(A_ThisHotkey, "left", "{left}")
        send, %thisHotkey%
        return
    }
^1::
selectPanel1:
    gui, main:default
    whichSide:=1
    updateWinTitle()

    keyboardFocusPane(1)
return

right:: ;always uses keyboard hook
^right::
    if (focused="changePath" or focused="searchCurrentDirEdit") {
        thisHotkey:=StrReplace(A_ThisHotkey, "Right", "{Right}")
        send, %thisHotkey%
        return
    }
^2::
selectPanel2:
    gui, main:default
    whichSide:=2
    updateWinTitle()

    keyboardFocusPane(2)
return

$NumpadAdd::
    pathOfSelectedImg:=getSelectedPaths()[1]
    if (focused="searchCurrentDirEdit" or focused="flistView" or focused="listViewInSearch") {
        Run,"C:\Program Files\XnViewMP\xnviewmp.exe" "%pathOfSelectedImg%", % EcurrentDir%whichSide%
    }
return

$NumpadEnter::
$RWin::
    if (focused="searchCurrentDirEdit" or focused="flistView" or focused="listViewInSearch") {
        Run,"C:\Program Files\Git\git-bash.exe", % EcurrentDir%whichSide%
    }
return

$RAlt::
    if (focused="searchCurrentDirEdit" or focused="flistView" or focused="listViewInSearch") {
        Run,"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe", % EcurrentDir%whichSide%
    }
return

$RCtrl::
    if (focused="searchCurrentDirEdit" or focused="flistView" or focused="listViewInSearch") {
        Run,"%ComSpec%", % EcurrentDir%whichSide%
    }
return
$RShift::
    if (focused="searchCurrentDirEdit" or focused="flistView" or focused="listViewInSearch") {
        ; `"C:\Program Files\Microsoft VS Code\Code.exe" "C:"` fails
        ; `"C:\Program Files\Microsoft VS Code\Code.exe" "C:\"` fails
        ; `"C:\Program Files\Microsoft VS Code\Code.exe" "C:\."` works
        VSCodeRunner(EcurrentDir%whichSide% "\.")
        WinWait % "ahk_exe Code.exe"
        WinMaximize % "ahk_exe Code.exe"
    } else {
        send, +\
    }
return

$\::
    Gui, main:Default
    if (focused="searchCurrentDirEdit" or focused="flistView" or focused="listViewInSearch") {
        selectedPaths:=getSelectedPaths()
        if (selectedPaths.Length()) {
            for k,v in selectedPaths {
                VSCodeRunner(v)
            }
        }
    } else {
        send, \
    }

return

$^+r::
    namesToMultiRename:=getSelectedNames()
    dCurrentDir:=RTrim(EcurrentDir%whichSide%, "\") "\"
    finalStr:=""
    for k, fileName in namesToMultiRename {
        if (k > 1) {
            finalStr.="`n"
        }
        finalStr.=dCurrentDir fileName
    }
    tempPath:=A_LineFile "\..\ahk_explorer multi-rename names"
    tempPath:=ComObjCreate("Scripting.FileSystemObject").GetAbsolutePathName(tempPath)
    FileDelete % tempPath
    FileAppend % finalStr, % "*" tempPath

    ; Shell := ComObjCreate("WScript.Shell")
    ; toRun:="cmd /k code.cmd --wait """ tempPath """"
    ; Clipboard:=toRun
    ; Exec := Shell.Exec(toRun)
    ; Exec.StdIn.Write("")
    ; Exec.StdIn.Close()
    ; Exec.StdOut.ReadAll() ;just wait for it to finish because RunWait doesn't work
    ; output:=Exec.StdOut.ReadAll()
    ; outputPath:=SubStr(output, 25, -1)
    ; RunWait % toRun

    ; MsgBox % IsFunc("RunCMD")
    RunCMD("code.cmd --wait """ tempPath """")

    FileRead, OutputVar, % tempPath
    newFileNamesArr:=StrSplit(OutputVar, "`n")

    for k, newFileName in newFileNamesArr {
        if (InStr(stuffByName%whichSide%[namesToMultiRename[k]].attri, "D")) {
            FileMoveDir % dCurrentDir namesToMultiRename[k], % newFileName
        } else {
            FileMove % dCurrentDir namesToMultiRename[k], % newFileName
        }
    }

/*
    namesToMultiRename:=getSelectedNames()
    multiRenameDir:=EcurrentDir%whichSide%
    multiRenamelength:=namesToMultiRename.Length()
    Gui, multiRenameGui:Default
    ; Gui,Font, s10, Segoe UI
    Gui,Font, s10, Consolas

    Gui, Add, Edit, w400 vmultiRenameTheName
    Gui, Add, Edit, x+5 w300 vmultiRenameStartingNums

    Gui, Add, Button, h30 w200 y+5 x+-705 ggmultiRenamePreview,preview
    Gui, Add, Button, h30 w200 x+5 ggmultiRenameApply,apply

    width:=500
    Gui, Add, ListBox, r%multiRenamelength% w%width% y+5 vvmultiRenameTargets x+-405 , % array_ToVerticleBarString(selectedNames)
    Gui, Add, ListBox, r%multiRenamelength% w%width% x+5 vvmultiRenamePreview,
    Gui, Add, Text, % "x+-" 2*width " y+10" ,|namenoext`n|name`n|ext`n*`n?
    Gui, show,,multiRenameGui
*/
return

$^r::
$esc::
    stopSearching()
return

$f2::
    gui, main:default ;NEEDED
    ControlFocus,, % "ahk_id " hwndListview%whichSide%
    Gui, ListView, vlistView%whichSide%


    canRename:=true
    ; focused:="renaming"
    firstRename:=false
    fromButton:=false
    renameTextWidthLimit:=200

    ; https://winaero.com/change-dpi-scaling-level-for-display-in-windows-10/
    ; it's everything x0.96
    ; it's A_ScreenDPI *25/24
    ; 96 = default 100%
    ; 120 = medium 125%
    ; 144 = larger 150%
    ; 192 = extra large 200%
    ; 240 = custom 250%
    ; 288 = custom 300%
    ; 384 = custom 400%
    ; 480 = custom 500%
    ; https://www.autohotkey.com/docs/commands/Gui.htm#DPIScale
    ; BRUH, IT'S PROPERTIONAL TO favoritesListViewWidth
    ; adding favoritesListViewWidth is not the same width
    ;130 is actually 162

    dpiMultiplier:=A_ScreenDPI/96


    row:=LV_GetNext("")

    WinGetPos, gui_x, gui_y,,, ahk_explorer ahk_class AutoHotkeyGUI
    ; Byref xpos, Byref ypos
    listview_getPosOfRow(hwndListview%whichSide%,row - 1, row_x, row_y)
    ControlGetPos, listview_X, listview_Y,,,, % "ahk_id " hwndListview%whichSide%
    xOffset_IconWidth:=dpiMultiplier*23
    yOffset_QualityOfLife:= -2
    xpos:=row_x + gui_x + listview_X + xOffset_IconWidth
    ypos:=row_y + gui_y + listview_Y + yOffset_QualityOfLife


    LV_GetText(TextBeingRenamed, row, 2)

    Gui, renameSimple:New, hwndrenamingHwnd
    Gui, renameSimple:Default
    Gui, Font, s10, Segoe UI
    Gui, Margin , 0,0,0,0
    gui, add, edit,y2 r1 w%renameTextWidthLimit% -wrap gTypingInRenameSimple vtextRenamingSimple hwndRenameHwnd, % TextBeingRenamed
    Gui, Add, Button, Hidden Default ggrenameFileLabel

    gui, show, X%xpos% Y%ypos% h0,renamingWinTitle
    ; WinSet, Style, -0xC00000, A ; remove the titlebar and border(s)
    WinSet, Style, -0xC00000, % "ahk_id " renamingHwnd ; remove the titlebar and border(s)


    resizeRenameEdit()
    SplitPath, TextBeingRenamed,, , , OutNameNoExt
    SendMessage,0xB1, 0, 0,, % "ahk_id " RenameHwnd
    attri:=stuffByName%whichSide%[TextBeingRenamed].attri
    if (InStr(attri, "D"))
        SendMessage, 0xB1,0,% StrLen(TextBeingRenamed),, % "ahk_id " RenameHwnd ;select all
    else
        SendMessage, 0xB1,0,% StrLen(OutNameNoExt),, % "ahk_id " RenameHwnd

    ; Gosub, TypingInRenameSimple
return

$^n::

return
$^+n::
    Gui, createFolder:Default

    creatingNewFolder:=true
    newFolderPath:=findNextDirNameNumberIteration(EcurrentDir%whichSide% "\New Folder *")
    SplitPath, newFolderPath, newFolderName
    strLen:=StrLen(newFolderName)
    if (SubStr(newFolderName, 0)=" " and strLen > 1) {
        newFolderName:=SubStr(newFolderName, 1, strLen-1)
    }

    if (!notFirstTimeCreatingFolder) {
        notFirstTimeCreatingFolder:=true
        Gui, createFolder: Font, s10, Segoe UI
        ;Segoe UI
        gui, createFolder: add, text,, Folder Name: ; Save this control's position and start a new section.
        gui, createFolder: add, edit, w250 vvcreateFolder ggcreateFolder hwndfolderCreationHwnd, %newFolderName%
        gui, createFolder: add, button, Default w125 x11 vcreate gcreateLabel,Create Folder`n{Enter}
        gui, createFolder: add, button, w125 x+2 vcreateAndOpen gcreateAndOpenLabel,Create and Open`n{Shift + Enter}
    } else {
        ; GuiControl, text, vcreateFolder, %newFolderName%
        ControlSetText,, %newFolderName%, ahk_id %folderCreationHwnd%
        SendMessage, 0xB1, 0, -1,, % "ahk_id " folderCreationHwnd
    }
    gui, createFolder: show,, create_folder

return
^s::
    selectedNames:=getSelectedNames()
    for notUsed, name in selectedNames {
        Run, "%spekPath%" "%name%", % EcurrentDir%whichSide%
    }
return

^+h::
    hashFiles("sha512","SHA-512")
return

!h::
    hashFiles("sha256","SHA-256")
return

^h::
    hashFiles("md5","MD5")
return

+h::
    hashFiles("sha1","SHA-1")
return

^+e::
    selectedNames:=getSelectedNames()
    for notUsed, name in selectedNames {
        SplitPath, name,,,, OutNameNoExt
        FileRecycle, % EcurrentDir%whichSide% "\" OutNameNoExt ".exe"
        Run, "%Ahk2ExePath%" /in "%name%" /bin "%Ahk2ExePath%\..\Unicode 32-bit.bin", % EcurrentDir%whichSide%
    }
return
!c::
copySelectedNames:
    Gui, main:Default
    selectedNames:=getSelectedNames()
    finalStr=
    length:=selectedNames.Length()
    for k, v in selectedNames {
        if (k=length) {
            finalStr.=v
        }
        else {
            finalStr.=v "`n"
        }
    }
    clipboard:=finalStr

    #Persistent
    ToolTip, % length
    SetTimer, RemoveToolTip,-1000
return

copySelectedPaths:
^+c::
    Gui, main:Default
    finalStr:=""
    selected_Paths:=getSelectedPaths()
    for k, v in selected_Paths {
        if (k==1) {
            finalStr.=v
        }
        else {
            finalStr.="`n" v
        }
    }
    clipboard:=finalStr

    #Persistent
    ToolTip, % selected_Paths.Length()
    SetTimer, RemoveToolTip,-1000
return

$!left::
    focusDirOnBack:=true
goToParentDir:
    Gui, main:Default
    SplitPath, % EcurrentDir%whichSide%,OutDirName, ParentDir1
    if (focusDirOnBack) {
        focusDirOnBack:=false
        toFocus:=OutDirName
    }

    EcurrentDir%whichSide%:=ParentDir1
    renderCurrentDir()
return

$!right::
    Gui, main:Default
    undoHistoryArr[whichSide].Push(EcurrentDir%whichSide%)
    EcurrentDir%whichSide%:=dirHistoryArr[whichSide].Pop()

    if (_render_Current_Dir()) {
        if (lastDir%whichSide%!=EcurrentDir%whichSide% ) {
            updateDirsToWatch()
        }
        lastDir%whichSide%:=EcurrentDir%whichSide%
    }
return

$!up::
    Gui, main:Default
    EcurrentDir%whichSide%:=undoHistoryArr[whichSide].Pop()
    renderCurrentDir()
return

^l::
/::
    focused:="changePath"
    ControlFocus,, % "ahk_id " Edithwnd%whichSide%
    SendMessage, 177, 0, -1,, % "ahk_id " Edithwnd%whichSide%
    ;// where does this go ?
    ;// goes to submitAndRenderDir()
return

$backspace::
    Gui, main:Default
    if (focused="changePath" or focused="renaming") {
        send, {backspace}
    } else if (focused="listViewInSearch") {
        if (searchString%whichSide%="") {
            stopSearching()
        } else {
            GuiControl, focus,vcurrentDirEdit%whichSide%
            SendMessage, 0xB1, -2, -1,, % "ahk_id " Edithwnd%whichSide%
            send, {backspace}
        }
    } else if (focused="searchCurrentDirEdit") {
        if (searchString%whichSide%="") {
            stopSearching()
        } else {
            send, {backspace}
        }
    } else if (focused="flistView") {
        gosub,goToParentDir
    }
return
$^+up::
    gosub, shiftUp
    gosub, shiftUp
return

shiftUp:
$+up::
    Gui, main:Default
    Gui, ListView, vlistView%whichSide%

    focusRow:=LV_GetNext(0, "F")

    before:=LV_GetNext(focusRow - 2)
    if (focusRow - 1 > 0) {
        if (before=focusRow - 1) {
            LV_Modify(focusRow, "-Select -Focus")
            LV_Modify(focusRow - 1,"+Select +Focus Vis")
        } else {
            LV_Modify(focusRow - 1,"+Select +Focus Vis")
        }
    } else {
        numberOfRows:=LV_GetCount()
        LV_Modify(numberOfRows,"+Select +Focus Vis")
    }
return
$^up::
    Gui, main:Default
    Gui, ListView, vlistView%whichSide%
    selectedRow:=LV_GetNext()
    rowToSelect:=selectedRow-1

    if (rowToSelect>0) {
        LV_Modify(rowToSelect, "+Select +Focus Vis") ; select
    }
return
$up::
    Gui, main:Default
    Gui, ListView, vlistView%whichSide%
    selectedRow:=LV_GetNext()
    numberOfRows:=LV_GetCount()
    loop % numberOfRows
    {
        LV_Modify(A_Index, "-Select -Focus") ; select
    }

    if (selectedRow<2) {
        LV_Modify(numberOfRows, "+Select +Focus Vis") ; select
    }
    else {
        LV_Modify(selectedRow-1, "+Select +Focus Vis") ; select
    }
return
$+home::
$+NumpadHome::
$^+home::
$^+NumpadHome::
    if (focused="changePath" or focused="searchCurrentDirEdit") {
        ; if (A_ThisHotkey == "$+home") {
            ; send, +{home}
        ; } else {
            ; send, +{NumpadHome}
        ; }
        send % SubStr(A_ThisHotkey, 2)
        return
    }
    Gui, main:Default
    Gui, ListView, vlistView%whichSide%
    selectedRow:=LV_GetNext()
    loop % selectedRow - 1 {
        LV_Modify(A_Index, "+Select +Focus Vis") ; select
    }

return
$+end::
$+NumpadEnd::
$^+end::
$^+NumpadEnd::
    if (focused="changePath" or focused="searchCurrentDirEdit") {
        ; send, +{end}
        send % SubStr(A_ThisHotkey, 2)
        return
    }
    Gui, main:Default
    Gui, ListView, vlistView%whichSide%
    selectedRow:=LV_GetNext()
    numberOfRows:=LV_GetCount()
    loop % numberOfRows - selectedRow
    {
        LV_Modify(A_Index + selectedRow, "+Select +Focus Vis") ; select
    }

return
selectCurrent:
    Gui, main:Default
    Gui, ListView, vlistView%whichSide%
    selectedRow:=LV_GetNext(,"F")
    LV_Modify(selectedRow, "-Select -Focus") ; select
    LV_Modify(selectedRow, "+Select +Focus Vis") ; select
return

$^+down::
    gosub, shiftDown
    gosub, shiftDown
return
shiftDown:
$+down::
    Gui, main:Default
    Gui, ListView, vlistView%whichSide%

    focusRow:=LV_GetNext(0, "F")
    after:=LV_GetNext(focusRow)
    numberOfRows:=LV_GetCount()

    if (focusRow < numberOfRows) {
        if (after=focusRow + 1) {
            LV_Modify(focusRow, "-Select -Focus")
            LV_Modify(focusRow + 1,"+Select +Focus Vis")
        } else {
            LV_Modify(focusRow + 1,"+Select +Focus Vis")
        }
    } else {
        LV_Modify(1,"+Select +Focus Vis")
    }

return
$^down::
    Gui, main:Default
    Gui, ListView, vlistView%whichSide%

    selectedRow:=0
    index:=0
    loop {
        index:=LV_GetNext(index)
        if (!index)
            break
        selectedRow:=index
    }
    LV_Modify(selectedRow+1, "+Select +Focus Vis") ; select
return

$down::
    Gui, main:Default
    Gui, ListView, vlistView%whichSide%

    selectedRows:=[]
    selectedRow:=0
    index:=0
    loop {
        index:=LV_GetNext(index)
        if (!index)
            break
        selectedRow:=index
        selectedRows.Push(index)
    }
    for k, v in selectedRows {
        LV_Modify(v, "-Select -Focus") ; select
    }

    numberOfRows:=LV_GetCount()
    if (selectedRow=0) {
        LV_Modify(1, "+Select +Focus Vis") ; select
    }
    else if (selectedRow < numberOfRows) {
        LV_Modify(selectedRow+1, "+Select +Focus Vis") ; select
    }
    else {
        LV_Modify(1, "+Select +Focus Vis") ; select
    }
return
;how to fix $enter not working ? why ?
;sign out and sign in fixed it
$enter::
    Gui, main:Default
    if (!canRename) {
        if (focused="flistView" or focused="searchCurrentDirEdit" or focused="listViewInSearch") {
            gui, ListView, vlistView%whichSide%
            for unused, fullPath in getSelectedPaths() {
                doubleClickedFolderOrFile(fullPath)
            }
            ; row:=LV_GetNext("")
            ; doubleClickedNormal(row)
            ControlFocus,, % "ahk_id " hwndListview%whichSide%
        } else if (focused="changePath" or focused="renaming") {
            ControlFocus,, % "ahk_id " hwndListview%whichSide%
        }
    } else {
        send, {enter}
    }

return

!f4::
    Process, Close, %PID_getFolderSizes%
    Exitapp
return

#if winactive("renamingWinTitle ahk_class AutoHotkeyGUI")

$esc::
    if (focused="flistView") {
        if (canRename) {
            canRename:=false
            ; gui, renameSimple:Default
            ; gui, submit
            gui, main:Default
            ControlFocus,, % "ahk_id " hwndListview%whichSide%

            gui, renameSimple:Default
            gui, destroy
        }
        return
    }
    send, {enter}
return

#if winactive("create_folder ahk_class AutoHotkeyGUI")

$enter::
    Gosub, createLabel

return

$+enter::
$^+enter::
    Gosub, createAndOpenLabel
return

