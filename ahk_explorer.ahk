#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, force
    SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#MaxThreads, 20
#MaxThreadsPerHotkey, 4
SetBatchLines, -1
SetTitleMatchMode, 2
currentDirSearch=
;%appdata%\ahk_explorer_settings
FileRead, favoriteFolders, %A_AppData%\ahk_explorer_settings\favoriteFolders.txt
favoriteFolders:=StrSplit(favoriteFolders,"`r`n")
FileRead, peazipPath, %A_AppData%\ahk_explorer_settings\peazipPath.txt
FileRead, vscodePath, %A_AppData%\ahk_explorer_settings\vscodePath.txt
FileRead, BGColorOfSelectedPane, %A_AppData%\ahk_explorer_settings\BGColorOfSelectedPane.txt
FileRead, BGColorOfSelectedPane, %A_AppData%\ahk_explorer_settings\BGColorOfSelectedPane.txt

EcurrentDir1=C:\Users\Public\AHK\notes\tests\File Watcher
; EcurrentDir1=C:\Users\User\Downloads
EcurrentDir2=C:\Users\Public\AHK
whichSide:=1
fileExist:=fileExist(EcurrentDir%whichSide%)
if (!InStr(fileExist, "D"))
    EcurrentDir%whichSide%:="C:"

for n, param in A_Args  ; For each parameter:
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
        p("the folder or file you are trying to open doesn't exist`r`nyou were trying to open:`r`n" param)
    }
    break
}
;vars
maxRows:=50
rememberIconNumber:=0
lastInputSearchCurrentDir:=false
dirHistory1:=[]
dirHistory2:=[]
undoHistory1:=[]
undoHistory2:=[]
global DROPEFFECT_NONE	:= 0
global DROPEFFECT_COPY	:= 1
global DROPEFFECT_MOVE	:= 2
global DROPEFFECT_LINK	:= 4
calculatefileSizes:=1
calculateDates:=1
doIcons:=1
global dropEffectFormat := DllCall("RegisterClipboardFormat", "Str", CFSTR_PREFERREDDROPEFFECT := "Preferred DropEffect", "UInt")
    

; clipboard:=A_Programs
Gui, main:Default
; Gui, Font, s12
Gui,Font, s10, Segoe UI

; Gui, Font, s10, Segoe UI

Gui, +LastFound
; Gui, +LastFound +Resize
hw_gui := WinExist()

Gui, Margin, 0, 0

folderListViewWidth:=250
favoritesListViewWidth:=130

listViewWidth:=500
Gui, Add, Button, h40 w%favoritesListViewWidth% gDriveButtonEvents vDriveButton Left,
; Gui, Add, Button,  w80, C:\`r`n7.06 GB/232.24 GB

; Gui, Add, ListView, 0x2000 h28 w%favoritesListViewWidth% +WantF2 -ReadOnly vdriveSpace AltSubmit ,C:\ `r`n7.06 GB/232.24 GB
; Gui, Add, ListView, r1 w%favoritesListViewWidth% y220 +WantF2 -ReadOnly vdriveSpace gdriveSpaceEvent AltSubmit ,Please enter your name:
favoritesLenght:=favoriteFolders.Length()
Gui, Add, ListView, r%favoritesLenght% w%favoritesListViewWidth% y+200 +WantF2 -ReadOnly vfavoritesListView gfavoritesListViewEvents AltSubmit ,Favorites

Gui, Add, ListView, r10 w%folderListViewWidth% y0 x+0 +WantF2 -ReadOnly vfolderListView1_1 gfolderlistViewEvents1_1 AltSubmit ,Name
Gui, Add, ListView, r10 w%folderListViewWidth% x+0 y0 +WantF2 -ReadOnly vfolderlistView2_1 gfolderlistViewEvents2_1 AltSubmit ,Name

Gui, Add, Edit, hwndEdithwnd1 r1 w%listViewWidth% y+0 x+-500 vvcurrentDirEdit1 gcurrentDirEdit1Changed, %EcurrentDir1%

; Gui, Add, Edit, w100 h100
; Gui, Add, Edit, w100 h100 vVarEdit2

; Gui, Color, 0x161616

Gui, Add, ListView, NoSort HwndListviewHwnd1 Count5000 r25 -WantF2 w%listViewWidth% -ReadOnly vvlistView1 glistViewEvents1 AltSubmit ,type|Name|Date|sortableDate|Size|sortableSize

Gui, Add, ListView, r10 w%folderListViewWidth% y0 x+0 +WantF2 -ReadOnly vfolderListView1_2 gfolderlistViewEvents1_2 AltSubmit ,Name
Gui, Add, ListView, r10 w%folderListViewWidth% x+0 y0 +WantF2 -ReadOnly vfolderlistView2_2 gfolderlistViewEvents2_2 AltSubmit ,Name
Gui, Add, Edit, hwndEdithwnd2 r1 w%listViewWidth% y+0 x+-500 vvcurrentDirEdit2 gcurrentDirEdit2Changed, %EcurrentDir2%
Gui, Add, ListView, NoSort HwndListviewHwnd2 Count5000 r25 -WantF2 w%listViewWidth% -ReadOnly vvlistView2 glistViewEvents2 AltSubmit ,type|Name|Date|sortableDate|Size|sortableSize
; Gui, Add, ListView, NoSort HwndListviewHwnd Count200 r25 w%listViewWidth% +WantF2 -ReadOnly vlistView glistViewEvents AltSubmit ,Name|Date|sortableDate|Size|sortableSize
;0x161616, 1305, 515
;   Gui, Font, cwhite
;   vvvvv:=["listView","favoritesListView","folderListView1","folderlistView2","currentDirEdit"]
;   for k,v in vvvvv{
;   GuiControl, +Background0x161616, %v%
; GuiControl, Font, %v%
;   }

; MyInstance := New LV_Colors(ListviewHwnd,true,false)
; MyInstance :=  LV_Colors.Attach(ListviewHwnd,true,false)
OnMessage(0x4A, "WM_COPYDATA_READ")

OnMessage(0x111, "HandleMessage" )
; MyInstance.
loop 2 {
    Gui, ListView, vlistView%A_Index%
    LV_Colors.OnMessage()
    LV_Colors.Attach(ListviewHwnd%A_Index%, 1, 0)
    
    LV_ModifyCol(1,20)
        LV_ModifyCol(2,300)
        LV_ModifyCol(3,"50 Right")
        LV_ModifyCol(5,"80 Right")
        LV_ModifyCol(6,"Integer")
        LV_ModifyCol(4,0) ; hides 3rd row
        LV_ModifyCol(6,0) ; hides 3rd row
        focused=flistView
    ImageListID%A_Index% := IL_Create(50)
    ; ImageListID1 := IL_Create(200)
    ; ImageListID1 := IL_Create(10)
    LV_SetImageList(ImageListID%A_Index%) ;desactivated this to test 
}

Gui, Show,,ahk_explorer
Gui, ListView, favoritesListView
favoriteFoldersNames:=[]
for k, v in favoriteFolders {
    ; if (InStr(fileExist(v), "D"))
    ; {
    SplitPath, v, OutFileName
    favoriteFoldersNames.Push(OutFileName)
    LV_Add(, OutFileName)
    ; }
}
whichSide:=1
renderCurrentDir()

; sleep, 1000
; 
; sleep, 1000

; currentDir=%A_Programs%

return

; f3::
Process, Close, %PID_getFolderSizes%
Exitapp
return

;labels
multiRenameGuiGuiClose:
    Gui, Destroy
return
gmultiRenameApply:
    multiRenameNames:=getMultiRenameNames()
    multiRenameNamesBak:=A.cloneDeep(multiRenameNames)
    namesToMultiRenameBak:=A.cloneDeep(namesToMultiRename)
    
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
            ; p(toRenamePath " | " renamedPath)
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
        renderCurrentDir()
    }
return
gmultiRenamePreview:
    Guicontrol, text, vmultiRenamePreview, % "|" array_ToVerticleBarString(getMultiRenameNames())
return
RemoveToolTip:
    ToolTip
return
TypingInRenameSimple:
    Gui,Submit,NoHide
    
    Size:=10
    Gui,Fake:Font,s%Size%,Segoe UI
    Gui,Fake:Add,Text, -Wrap vDummy,% RenamingSimple
    GuiControlGet,Pos,Fake:Pos,Dummy
    Gui,Fake:Destroy
    
    if (posw+ 2 * Size>renameTextWidthLimit) {
        renameTextWidthLimit:=(posw+ 2 * Size) +  (8 * Size)
        width:=renameTextWidthLimit
        GuiControl Move,RenamingSimple, W%width%
        Guiwidth:=width+2
        Gui, Show, W%Guiwidth%
    }
    if (!firstRename) {
        firstRename:=true
        SplitPath, TextBeingRenamed,, , , OutNameNoExt
        SendMessage,0xB1, 0, 0, , ahk_id %RenameHwnd%
        fileExist:=fileExist(EcurrentDir%whichSide% "\" TextBeingRenamed)
        if (InStr(fileExist, "D"))
            SendMessage, 0xB1,0,% StrLen(TextBeingRenamed),, ahk_id %RenameHwnd%
        else
            SendMessage, 0xB1,0,% StrLen(OutNameNoExt),, ahk_id %RenameHwnd%
    } else {
        ControlGet, Outvar ,CurrentCol,, Edit1
        Outvar -=1
        Postmessage,0xB1, 0, 0, Edit1
        Postmessage,0xB1,%Outvar%,%Outvar%, Edit1
        
        
    }
return
grenameFileLabel:
    fromButton:=true
renameFileLabel:
    if (canRename) {
        canRename:=false
        gui, renameSimple:Default
        gui, submit
        gui, main:Default
        
        if (TextBeingRenamed!=RenamingSimple) {
            if (stuffByName[RenamingSimple].Count()) {
                p("file with same name")
            } else {
                LV_Modify(row,,, RenamingSimple)
                    stuffByName[RenamingSimple]:=stuffByName[TextBeingRenamed]
                stuffByName.Delete(TextBeingRenamed)
                for k, v in stuffByName {
                    if (v=TextBeingRenamed) {
                        stuffByName.RemoveAt(k)
                        stuffByName.InsertAt(k, RenamingSimple)
                    }
                }
                for k, v in sortedByDate {
                    if (sortedByDate[k]["name"]=TextBeingRenamed) {
                        sortedByDate[k]["name"]:=RenamingSimple
                    }
                }
                SourcePath:=EcurrentDir%whichSide% "\" TextBeingRenamed
                DestPath:=EcurrentDir%whichSide% "\" RenamingSimple
                fileExist:=FileExist(SourcePath)
                if (fileExist) {
                    if (InStr(fileExist, "D")) {
                        ; p("FileMoveDir")
                        ;C:\Users\User\Downloads\Class_LV_Colors-0
                        FileMoveDir, %SourcePath%, %DestPath%
                    } else {
                        ; p("FileMove")
                        FileMove, %SourcePath%, %DestPath%
                    }
                    if ErrorLevel
                        p("file could not be moved")
                    SoundPlay, *-1
                }
            }
        }
        gui, renameSimple:Default
        
        gui, destroy
        gui, main:Default
        if (fromButton) {
            fromButton:=false
            ControlFocus,, % "ahk_id " ListviewHwnd%whichSide%
        }
        
    }
return

DriveButtonEvents:
    EcurrentDir%whichSide%:="C:"
    renderCurrentDir()
return

mainGuiClose:
    Process, Close, %PID_getFolderSizes%
    
    Exitapp
return

couldNotCreateFolder()
{
    global
    Gui, createFolder:Default
    creatingNewFolder:=true
    dontSearch:=true
    ControlSetText,, %createFolderName%, ahk_id %folderCreationHwnd%
    SendMessage, 0xB1, 0, -1,, % "ahk_id " folderCreationHwnd
    gui, createFolder: show,, create_folder
    dontSearch:=false
}

createLabel:
    gui, createFolder: submit
    toCreate:=EcurrentDir%whichSide% "\" createFolderName
    if (!fileExist(toCreate)) {
        FileCreateDir, %toCreate%
        if (ErrorLevel) {
            SoundPlay, *16
            p("Could not create Folder, illegal name or idk")
            couldNotCreateFolder()
        } else {
            Gui, main:Default
            SoundPlay, *-1
            renderCurrentDir()
        }
    } else {
        SoundPlay, *16
        p("folder already exists")
        couldNotCreateFolder()
    }
return

createAndOpenLabel:
    gui, createFolder: submit
    toCreate:=EcurrentDir%whichSide% "\" createFolderName
    if (!fileExist(toCreate)) {
        FileCreateDir, %toCreate%
        if (ErrorLevel) {
            SoundPlay, *16
            p("Could not create Folder, illegal name or idk")
            couldNotCreateFolder()
        } else {
            EcurrentDir%whichSide%:=toCreate
            Gui, main:Default
            SoundPlay, *-1
            renderCurrentDir()
        }
    } else {
        SoundPlay, *16
        p("folder already exists")
        couldNotCreateFolder()
    }
return

favoritesListViewEvents:
    if (A_GuiEvent = "DoubleClick") {
        Gui, ListView, favoritesListView
        doubleClickedFolderOrFile(favoriteFolders[A_EventInfo])
    }
return

folderlistViewEvents1_1:
folderlistViewEvents2_1:
folderlistViewEvents1_2:
folderlistViewEvents2_2:
    whichSide:=SubStr(A_GuiControl, 0)
    num:=SubStr(A_GuiControl, 15, 1)
    whichParent:=(num=1) ? 2 : 1
    Gui, Show,NA,% EcurrentDir%whichSide% " - ahk_explorer"
    
    if (A_GuiEvent="ColClick")
    {
        EcurrentDir%whichSide%:=parent%whichParent%Dir%whichSide%
        renderCurrentDir()
    } else if (A_GuiEvent = "DoubleClick") {
        EcurrentDir%whichSide%:=parent%whichParent%DirDirs%whichSide%[A_EventInfo]
        renderCurrentDir()
    }
return
; folderlistViewEvents2_1:
    whichSide:=1
    Gui, Show,NA,% EcurrentDir%whichSide% " - ahk_explorer"
    
    if (A_GuiEvent="ColClick")
    {
        EcurrentDir%whichSide%:=parent1Dir%whichSide%
        renderCurrentDir()
    } else if (A_GuiEvent = "DoubleClick") {
        EcurrentDir%whichSide%:=parent1DirDirs%whichSide%[A_EventInfo]
        renderCurrentDir()
    }
return
; folderlistViewEvents1_2:
    whichSide:=2
    Gui, Show,NA,% EcurrentDir%whichSide% " - ahk_explorer"
    if (A_GuiEvent="ColClick")
    {
        EcurrentDir%whichSide%:=parent2Dir%whichSide%
        renderCurrentDir()
    } else if (A_GuiEvent = "DoubleClick") {
        EcurrentDir%whichSide%:=parent2DirDirs%whichSide%[A_EventInfo]
        renderCurrentDir()
    }
return
; folderlistViewEvents2_2:
    whichSide:=2
    Gui, Show,NA,% EcurrentDir%whichSide% " - ahk_explorer"
    if (A_GuiEvent="ColClick")
    {
        EcurrentDir%whichSide%:=parent1Dir%whichSide%
        renderCurrentDir()
    } else if (A_GuiEvent = "DoubleClick") {
        EcurrentDir%whichSide%:=parent1DirDirs%whichSide%[A_EventInfo]
        renderCurrentDir()
    }
return
currentDirEdit1Changed:
currentDirEdit2Changed:
    SetTimer, currentDirEdit1ChangedTimer, -0
return
currentDirEdit1ChangedTimer:
    
    Gui, main:Default
    gui, submit, nohide
    if (focused="searchCurrentDirEdit")
    {
        if (vcurrentDirEdit%whichSide%!=lastEditText)
            lastEditText:=vcurrentDirEdit%whichSide%
        if (!submittingGui) {
            searchString%whichSide%:=vcurrentDirEdit%whichSide%
            searchInCurrentDir()
        }  else  {
            p(6456) 
            queueSubmitGui:=true
        }
    }
return
listViewEvents1:
listViewEvents2:
    whichSide:=SubStr(A_GuiControl, 0)
    if (A_GuiEvent=="D") {
        selectedPaths:=getSelectedPaths()
        
        FileToClipboard(selectedPaths)
        
        Cursors := []
        Cursors[1] := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32515, "UPtr") ; DROPEFFECT_COPY = IDC_CROSS
        Cursors[2] := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32516, "UPtr") ; DROPEFFECT_MOVE = IDC_UPARROW
        Cursors[3] := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32648, "UPtr") ; Copy or Move = IDC_NO
        DoDragDrop(Cursors)
    }
    else if (A_GuiEvent=="F") {
        Gui, Show,NA,% EcurrentDir%whichSide% " - ahk_explorer"
        
        If (ICELV%whichSide%["Changed"]) {
            Msg := ""
            p(ICELV%whichSide%.Changed["Txt"])
            ICELV%whichSide%.Remove("Changed")
        }
    }
    else if (A_GuiEvent=="e") {
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
        doubleClickedNormal(A_EventInfo)
    }
    else if (A_GuiEvent=="K") ;key pressed
    {
        if (!dontSearch) {
            ControlFocus,, % "ahk_id " ListviewHwnd%whichSide%
            Gui, ListView, vlistView%whichSide%
            
            key := GetKeyName(Format("vk{:x}", A_EventInfo))
            if (key="Backspace")
            {
            }
            else if (key="f2") {
                canRename:=true
                ; focused:="renaming"
                firstRename:=false
                fromButton:=false
                renameTextWidthLimit:=200
                
                row:=LV_GetNext("")
                LV_GetText(TextBeingRenamed, row, 2)
                ICELV%whichSide%.EditCell(row, 2)
                ; return
                sleep, 25
                ; ControlGet, hCtl, Hwnd,, Edit2
                ; ControlGet, hCtl2, Hwnd, , , , %text%
                ; 
                ; p(hCtl2 " " hCtl)
                ; WinGetPos, xpos, ypos,,, % "ahk_id " hCtl
                
                ; ControlGetPos , X, Y,,, Edit2 ;, WinTitle, WinText, ExcludeTitle, ExcludeText
                ; WinGetPos, xpos, ypos,,, % "ahk_id " hCtl
                WinGetPos, xpos, ypos,,,% ahk_explorer ahk_class AutoHotkeyGUI
                if (whichSide=1)
                    xpos+=161
                else
                    xpos+=161+listViewWidth
                
                ypos+=A_CaretY - 5
                Gui, renameSimple:Default
                Gui,Font, s10, Segoe UI
                Gui, Margin , 0,0,0,0
                gui, add, edit,y2 r1 w%renameTextWidthLimit% -wrap gTypingInRenameSimple vRenamingSimple hwndRenameHwnd, %TextBeingRenamed%
                Gui, Add, Button, Hidden Default ggrenameFileLabel
                
                
                
                ; xpos-=4
                ; ypos-=3
                ; WinSet, Style, -0xC00000,a ; remove the titlebar and border(s) 
                gui, show,  X%xpos% Y%ypos% h0,renamingWinTitle
                WinSet, Style, -0xC00000,a ; remove the titlebar and border(s) 
                
                gosub, TypingInRenameSimple
                
                sleep, 500
                
                return
                
                
                LV_GetText(OutputVar,A_EventInfo,2)
                SplitPath, OutputVar, , , OutExtension, OutNameNoExt
                if (OutNameNoExt) {
                    Postmessage,0xB1, 0, % StrLen(OutNameNoExt), Edit2
                } else {
                    Postmessage,0xB1, 1, % StrLen(OutExtension)+1, Edit2
                }
            }
            else if (key="Lwin") {
                
            }
            else if (key="NumpadRight") {
                
            }
            else if (key="NumpadLeft") {
                
            }
            else if (key="NumpadUp") {
                
            }
            else if (key="NumpadDown") {
                
            }
            else if (key="Alt") {
                
            }
            else if (key="Control") {
                
            }
            else if (key="Shift") {
                
            }
            else if (key="F1") {
                send, {f1}
            }
            else if (key="\") {
            }
            else if (key="NumpadEnd") {
            }
            else if (key="Numpad0") {
            }
            else if (key="NumpadHome") {
            }
            else if (key="NumpadPgDn") {
            }
            else if (key="NumpadPgUp") {
            }
            else if (key="]") {
            }
            else if (key="NumpadDel") {
                
                indexes:=[]
                selectedNames:=[]
                loop {
                    index:=LV_GetNext(0)
                    LV_GetText(OutputVar,index,2)
                    if (!index)
                        break
                    LV_Delete(index)
                    selectedNames.Push(OutputVar)
                }
                gosub, selectCurrent
                for k, v in selectedNames {
                    FileRecycle, % EcurrentDir%whichSide% "\" v
                    if (ErrorLevel=1) {
                        p("File is in use or Requires PERMISSION to delete")
                        return
                    }
                }
                SoundPlay, *-1
                
            } else {
                if (focused!="searchCurrentDirEdit")
                {
                    ShiftIsDown := GetKeyState("Shift")
                        CtrlIsDown := GetKeyState("Ctrl")
                    if (CtrlIsDown and !ShiftIsDown) {
                        if (key="c") {
                            selectedPaths:=getSelectedPaths()
                            FileToClipboard(selectedPaths)
                        }
                        else if (key="x") {
                            selectedPaths:=getSelectedPaths()
                            FileToClipboard(selectedPaths, "cut")
                        } else if (key="v") 
                        {
                            pasteFile()
                            
                        }   else if (key="a") {
                            loop % LV_GetCount()
                            {
                                LV_Modify(A_Index, "+Select") ; select                            
                                    ; LV_Modify(A_Index, "+Select +Focus") ; select                            
                            }
                        }
                        return
                        
                    } else if (CtrlIsDown and ShiftIsDown) {
                        if (key="x") {
                            for k, v in getSelectedNames() ;extract using 7zip, 7-zip
                            {
                                SplitPath, v,,,, OutNameNoExt
                                runwait, % "lib\7z x """ EcurrentDir%whichSide% "\" v """ -o""" EcurrentDir%whichSide% "\" OutNameNoExt """ -spe",,Hide
                                ; runwait, """" peazipPath """ -ext2folder """ EcurrentDir%whichSide% "\" v """"
                            }
                            soundplay, *-1
                            EcurrentDir%whichSide%:=EcurrentDir%whichSide% "\" OutNameNoExt
                            renderCurrentDir()                
                            return
                        } else if (key="d") {
                            files:=array_ToSpacedString(getSelectedPaths()) 
                            runwait, "%peazipPath%" -add2archive %files%
                            soundplay, *-1
                            renderCurrentDir()   
                            return
                        } else if (key="v") {
                            ; if (whichSide=1) {
                            ; 
                            ; gosub, selectPanel2
                            ; } else {
                            ; gosub, selectPanel1
                            ; }
                            gui, main:default
                            whichSideBak:=whichSide
                            whichSide:=(whichSide=1) ? 2 : 1
                            Gui, Show,NA,% EcurrentDir%whichSide% " - ahk_explorer"
                            ; sleep, 1000
                            GuiControl, Focus, vlistView%whichSide% ;bad code
                            ControlFocus,, % "ahk_id " ListviewHwnd%whichSide%
                            GuiControl, +Background%BGColorOfSelectedPane%, vlistView%whichSide%
                            GuiControl, +BackgroundWhite, vlistView%whichSideBak%
                            
                            
                            ; p(whichSide)
                            ControlFocus,, % "ahk_id " ListviewHwnd%whichSide%
                            Gui, ListView, vlistView%whichSide%
                            
                            pasteFile()
                            return
                            
                        } 
                    }
                    if (CtrlIsDown or ShiftIsDown)
                        return
                    
                    focused=searchCurrentDirEdit
                    ; focused=searchCurrentDirEdit%whichSide%
                    GuiControl, Focus, vcurrentDirEdit%whichSide%
                    GuiControl, Text, vcurrentDirEdit%whichSide%,% searchString%whichSide% key
                    SendMessage, 0xB1, -2, -1,, % "ahk_id " Edithwnd%whichSide%
                }
            } 
        }
    }
    else if (A_GuiEvent="RightClick") {
        selectedNames:=getSelectedNames()
        ShellContextMenu(EcurrentDir%whichSide%,selectedNames)
    }
    else if (A_GuiEvent="ColClick")
    {
        columnsToSort:=[1,2,4,6]
        if (A_EventInfo=1) {
            if (!foldersFirst)
            {   
                foldersFirst:=true
                sortColumn(1, "SortDesc")
            } else {
                foldersFirst:=false    
                sortColumn(1, "Sort")
            }
        } else if (A_EventInfo=2) {
            if (!z_ASort)
            {   
                z_ASort:=true
                sortColumn(2, "SortDesc")
            } else {
                z_ASort:=false    
                sortColumn(2, "Sort")
            }
        } else if (A_EventInfo=3)  {
            if (!newOld)
            {   
                newOld:=true    
                
                renderFunctionsToSort(sortedByDate%whichSide%, true)
                ; sortColumn(4, "SortDesc")
            } else {
                newOld:=false    
                renderFunctionsToSort(sortedByDate%whichSide%)
                ; sortColumn(4, "Sort")
            }
        } else if (A_EventInfo=5) {
            if (canSortBySize%whichSide%) {
                if (!bigSmall)
                {   
                    bigSmall:=true    
                    renderFunctionsToSort(sortedBySize%whichSide%)
                    
                    ; sortColumn(6, "SortDesc")
                } else {
                    bigSmall:=false    
                    renderFunctionsToSort(sortedBySize%whichSide%, true)
                    ; sortColumn(6, "Sort")
                }
            }
        }
    }
    
return
;includes
#include <biga>
#include <Class_LV_InCellEdit>
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
    Static Critical := 100
    ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ; META FUNCTIONS ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    __New(P*) {
        Return False   ; There is no reason to instantiate this class!
    }
    ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ; PRIVATE METHODS +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    On_NM_CUSTOMDRAW(H, L) {
        Static CDDS_PREPAINT          := 0x00000001
        Static CDDS_ITEMPREPAINT      := 0x00010001
        Static CDDS_SUBITEMPREPAINT   := 0x00030001
        Static CDRF_DODEFAULT         := 0x00000000
        Static CDRF_NEWFONT           := 0x00000002
        Static CDRF_NOTIFYITEMDRAW    := 0x00000020
            Static CDRF_NOTIFYSUBITEMDRAW := 0x00000020
            Static CLRDEFAULT             := 0xFF000000
        ; Size off NMHDR structure
        Static NMHDRSize := (2 * A_PtrSize) + 4 + (A_PtrSize - 4)
        ; Offset of dwItemSpec (NMCUSTOMDRAW)
        Static ItemSpecP := NMHDRSize + (5 * 4) + A_PtrSize + (A_PtrSize - 4)
        ; Size of NMCUSTOMDRAW structure
        Static NCDSize  := NMHDRSize + (6 * 4) + (3 * A_PtrSize) + (2 * (A_PtrSize - 4))
        ; Offset of clrText (NMLVCUSTOMDRAW)
        Static ClrTxP   :=  NCDSize
        ; Offset of clrTextBk (NMLVCUSTOMDRAW)
        Static ClrTxBkP := ClrTxP + 4
        ; Offset of iSubItem (NMLVCUSTOMDRAW)
        Static SubItemP := ClrTxBkP + 4
        ; Offset of clrFace (NMLVCUSTOMDRAW)
        Static ClrBkP   := SubItemP + 8
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
    Static LVM_GETBKCOLOR     := 0x1000
    Static LVM_GETHEADER      := 0x101F
    Static LVM_GETTEXTBKCOLOR := 0x1025
    Static LVM_GETTEXTCOLOR   := 0x1023
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
revealFileInExplorer(folderPath, files)
{
    COM_CoUninitialize()
    COM_CoInitialize()
    DllCall("shell32\SHParseDisplayName", "Wstr", folderPath, "Uint", 0, "Ptr*", pidl, "Uint", 0, "Uint", 0)
    DllCall("shell32\SHBindToObject","Ptr",0,"Ptr",pidl,"Ptr",0,"Ptr",GUID4String(IID_IShellFolder,"{000214E6-0000-0000-C000-000000000046}"),"Ptr*",pIShellFolder)
    length:=files.Length()
    VarSetCapacity(apidl, length * A_PtrSize, 0)
    for k, v in files {
        ;IShellFolder:ParseDisplayName 
        DllCall(VTable(pIShellFolder,3),"Ptr", pIShellFolder,"Ptr",win_hwnd,"Ptr",0,"Wstr",v,"Uint*",0,"Ptr*",tmpPIDL,"Uint*",0)
        NumPut(tmpPIDL, apidl, (k - 1)*A_PtrSize, "Ptr")
    }
    ; DllCall(140733176445120, "Ptr", pidl, "UINT", length, "Ptr", &apidl, "Uint", 0)
    DllCall("shell32\SHOpenFolderAndSelectItems", "Ptr", pidl, "UINT", length, "Ptr", &apidl, "Uint", 0)
    
    ; "Uint",length,"Ptr",&apidl,"Ptr",GUID4String(IID_IContextMenu,"{000214E4-0000-0000-C000-000000000046}"),"UINT*",0,"Ptr*",pIContextMenu)
    COM_CoUninitialize()
}
COM_CoInitialize()
{
Return	DllCall("ole32\CoInitialize", "Uint", 0)
}

COM_CoUninitialize()
{
    DllCall("ole32\CoUninitialize")
}

startWatchFolder(WatchedFolder)
{
    global
    If !WatchFolder(WatchedFolder, "Watch" whichSide, 0, 3) { ;files and folders
        MsgBox, 0, Error, Call of WatchFolder() failed!
        Return
    }
}
stopWatchFolder(WatchedFolder) 
{
    global
    WatchFolder(WatchedFolder, "**DEL")
}
pauseWatchFolder(WatchedFolder) 
{
    global
    WatchFolder("**PAUSE", True)
}
resumeWatchFolder(WatchedFolder) 
{
    global
    WatchFolder("**PAUSE", False)
}
Watch1(Folder, Changes) {
    Static Actions := ["1 (added)", "2 (removed)", "3 (modified)", "4 (renamed)"]
    For Each, Change In Changes {
        if (Change.Action=1) {
            fileAdded(1, Change.Name)
        }
    }
    ; p(TickCount, Folder, Actions[Change.Action], Change.Name, Change.IsDir, Change.OldName)
}
Watch2(Folder, Changes) {
    Static Actions := ["1 (added)", "2 (removed)", "3 (modified)", "4 (renamed)"]
    For Each, Change In Changes {
        if (Change.Action=1) {
            fileAdded(2, Change.Name)
        }
    }
    ; p(TickCount, Folder, Actions[Change.Action], Change.Name, Change.IsDir, Change.OldName)
}

fileAdded(whichSide, Byref path) {
    global
    sortWithAr%whichSide%:=[]
    
    FileGetSize, outputSize, v
    FileGetAttrib, OutputAttri , v
    
    stuffByName%whichSide%[v]:={date:A_Now,attri:OutputAttri,size:outputSize}
    sortedByDate%whichSide%.InsertAt(1,v)
    p(sortedBySize%whichSide%)
    sizesCopy%whichSide%:=A.Clone(sortedBySize%whichSide%)
    sizesCopy%whichSide%.Push(v)
    for key, value in sortedBySize%whichSide% {
        sortWithAr%whichSide%.Push({name:value, size:stuffByName%whichSide%[value]["size"]})
    }
    sortWithAr%whichSide%.Push({name:v, size:outputSize})
    p("length " sizesCopy%whichSide%.Length() "|" sortWithAr%whichSide%.Length())
    sortArrayByArray(sizesCopy%whichSide%,sortWithAr%whichSide%,true,"date")
    
    
    sortedBySize%whichSide%:=sizesCopy%whichSide%
    
    ; stuffByName
    ; unsorted
    ; sortedByDate
    ; sortedBySize
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
            if (effect & DROPEFFECT_COPY) {
                files:=StrSplit(clipboard, "`r`n")
                for k, v in files {
                    fileExist:=FileExist(v)
                    if (fileExist) {
                        SplitPath, v , OutFileName
                        if (InStr(fileExist, "D")) {
                            FileCopyDir, %v%, % EcurrentDir%whichSide% "\" OutFileName
                        } else {
                            FileCopy, %v%, % EcurrentDir%whichSide%
                        }
                    }
                }
                renderCurrentDir()
                SoundPlay, *-1
            }
            ; action:="copy"
            else if (effect & DROPEFFECT_MOVE) {
                files:=StrSplit(clipboard, "`r`n")
                if (files.Length()) {
                    fromOtherSide:=false
                    otherSide:=(whichSide=1) ? 2 : 1
                    for k, v in files {
                        fileExist:=FileExist(v)
                        if (fileExist) {
                            SplitPath, v , OutFileName, OutDir
                            if (Outdir=EcurrentDir%otherSide%) {
                                fromOtherSide:=true
                            }
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
                    renderCurrentDir()
                    
                    if (fromOtherSide) {
                        sideBak:=whichSide
                        whichSide:=otherSide
                        renderCurrentDir()
                        whichSide:=sideBak
                        ControlFocus,, % "ahk_id " ListviewHwnd%sideBak%
                        Gui, ListView, vlistView%sideBak%
                        whichSide:=sideBak
                        Gui, Show,NA,% EcurrentDir%whichSide% " - ahk_explorer"
                    }
                    
                    SoundPlay, *-1
                }
                
            }
            ; action:="move"
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
    VarSetCapacity(ZeroPaddedNumber, 20)  ; Ensure the variable is large enough to accept the new string.
    DllCall("wsprintf", "Str", ZeroPaddedNumber, "Str", "%0" howManyChars "d", "Int", number, "Cdecl")  ; Requires the Cdecl calling convention.
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
            } 
            charIndex++
        }
        for key, value in asterisksAndQmarks {
            num:=(startingNums[key]) ? startingNums[key] : 1
            actualNum:=num+k-1
            if (InStr(value, "?" )) {
                actualNum:=paddedNumber(actualNum, StrLen(value))
            }
            nameInstance:=StrReplace(nameInstance, value , actualNum,, 1)
        }
        SplitPath, v,,, OutExtension
        nameInstance:=StrReplace(nameInstance, "<ext>" , OutExtension)
        
        fileExist:=fileExist(multiRenameDir "\" v)
        if (InStr(fileExist, "D" )) {
            nameInstance:=StrReplace(nameInstance, "<Dext>" , "")
            nameInstance:=StrReplace(nameInstance, "<.Dext>" , "")
        } else {
            nameInstance:=StrReplace(nameInstance, "<Dext>" , OutExtension)
            nameInstance:=StrReplace(nameInstance, "<.Dext>" , "." OutExtension)
        }
        previewNames.Push(nameInstance)
        
    }
return previewNames
}

getTextWidth(text)
{
    global Dummy
    Gui,Fake:Font,s10,Segoe UI
    Gui,Fake:Add,Text, -Wrap vDummy,% text
    GuiControlGet,Pos,Fake:Pos,Dummy
    Gui,Fake:Destroy
return posw
}
calculateStuff(ByRef date,ByRef attri, ByRef size, ByRef name, Byref k) {
    global
    if (calculateDates) {
        now:=A_Now
        var1Num := now
        var2 := date
        EnvSub, var1Num, %var2%, Minutes
        var1:=var1Num "’"
        color=0xFF0000 ;red
        if (var1Num>525599) {
            var1Num := now
            EnvSub, var1Num, %var2%, Days
            var1Num:=Floor(var1Num/365.25) ;the average days in a month
            var1:=var1Num " y"
            color=0x808080 ;grey ; pink
        }
        else if (var1Num>86399) {
            var1Num := now
            EnvSub, var1Num, %var2%, Days
            var1Num:=Floor(var1Num/30.44) ;the average days in a month
            var1:=var1Num " m"
            color=0x00FFFF ;AQUA
        }
        else if (var1Num>1439) {
            var1Num := now
            EnvSub, var1Num, %var2%, Days
            var1:=var1Num " d"
            color=0x00FF00 ;lime green
        } else if (var1Num>59) {
            var1Num := now
            EnvSub, var1Num, %var2%, Hours
            var1:=var1Num " h"
            color=0xFFFF00 ;yellow
        }
    }
    if (calculatefileSizes) {
        bytes:=""
        formattedBytes:=""
            ; isDir:=""
        ; if (InStr(attri,"D")) {
        
        ; } else {
        bytes:=size
        ; }
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
        sortedBySize%whichSide%:=sortArrayByArray(unsorted%whichSide%,stuffByName%whichSide%,true,"size")
        canSortBySize%whichSide%:=true
    }
}
applyIcons(byref names) {
    global
    if (doIcons) {
        for k, v in names {
            hIcon := DllCall("Shell32\ExtractAssociatedIcon", UInt, 0, Str, EcurrentDir%whichSide% "\" v , UShortP, iIndex)
            if hIcon
            {
                ; DllCall("ImageList_ReplaceIcon", UInt, ImageListID1, Int, -1, UInt, hIcon)
                IconNumber := DllCall("ImageList_ReplaceIcon", UInt, ImageListID%whichSide%, Int, -1, UInt, hIcon) + 1
                DllCall("DestroyIcon", Uint, hIcon)
            }
            else
                IconNumber = 1
            
            LV_Modify(k,"Icon" . IconNumber)
                lastIconNumber:=IconNumber
        }
        
    }
}

renderFunctionsToSort(ByRef objectToSort, reverse:=false)
{
    global
    Gui, main:Default
    Gui, ListView, vlistView%whichSide%
    ControlFocus,, % "ahk_id " ListviewHwnd%whichSide%
    
    GuiControl,Text,vcurrentDirEdit%whichSide%, % EcurrentDir%whichSide%
    searchString%whichSide%=
    
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
    namesForIcons%whichSide%:=[]
        namesForSizes%whichSide%:=[]
        rowsForSizes%whichSide%:=[]
        
    if (length<=maxRows) {
        rowsToLoop:=length
    } else {
        rowsToLoop:=maxRows
        if (toFocus) {
            loop % length {
                if (toFocus=objectToSort[k]) {
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
    loop % rowsToLoop {
        name:=objectToSort[k]
        v:=stuffByName%whichSide%[name]
        if (!quickFixIcon) {
            quickFixIcon:=true
            hIcon:=DllCall("Shell32\ExtractAssociatedIcon", UInt, 0, Str, "", UShortP, iIndex)
            if hIcon
            {
                ; DllCall("ImageList_ReplaceIcon", UInt, ImageListID1, Int, -1, UInt, hIcon)
                IconNumber := DllCall("ImageList_ReplaceIcon", UInt, ImageListID1, Int, -1, UInt, hIcon) + 1
                DllCall("DestroyIcon", Uint, hIcon)
            }
            else
                IconNumber = 1
            LV_Modify(k,"Icon" . IconNumber)
                lastIconNumber:=IconNumber
            ; lastIconNumber:=IconNumber
        }
        calculateStuff(v["date"],v["attri"],v["size"],name,A_Index)
        if (name=toFocus)
        {
            rowToFocus:=A_Index
        }
        LV_Add(,,name,var1,var2,formattedBytes,bytes)
            ; LV_Add("Icon" . IconNumber,,name,var1,var2,formattedBytes,bytes)
        LV_Colors.Cell(ListviewHwnd%whichSide%,A_Index,3,color)
        namesForIcons%whichSide%.Push(name)
            k+=inc
    }
    if (toFocus)
    {
        LV_Modify(rowToFocus, "+Select +Focus")
    } else {
        LV_Modify(1, "+Select +Focus")
        }
    toFocus:=false
    if (!firstIce%whichSide%) {
        firstIce%whichSide%:=true
        ICELV%whichSide% := New LV_InCellEdit(ListviewHwnd%whichSide%, false, true)
        ICELV%whichSide%.SetColumns(0)
    }
    GuiControl, +Redraw, vlistView%whichSide% 
    applyIcons(namesForIcons%whichSide%)
    if (firstSizes%whichSide%) {
        firstSizes%whichSide%:=false
        for key in objectToSort {
            if (reverse) {
                k:=length-key+1
            } else {
                k:=key
            }
            name:=objectToSort[k]
            v:=stuffByName%whichSide%[name]
            if (InStr(v["attri"], "D")) {
                if (key<51)
                    rowsForSizes%whichSide%.Push(key)
                    namesForSizes%whichSide%.Push(name)
                }
        }       
        applySizes()
    }
    stopSizes:=true
}

manageCMDArguments(pathArgument)
{
    global
    Gui, main:Default
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
        p("the folder or file you are trying to open doesn't exist`r`nyou were trying to open: pathArgument=`r`n" pathArgument)
        clipboard:=pathArgument
        cmdFileExist:=fileExist(pathArgument)
        p(cmdFileExist " pathArgument was copied to clip" )
    }
    winactivate, ahk_explorer ahk_class AutoHotkeyGUI
    renderCurrentDir()
    ControlFocus,, % "ahk_id " ListviewHwnd%whichSide%
}

receivedFolderSize(string) {
    global
    Gui, main:Default
    Gui, ListView, vlistView%whichSide%
    ar:=StrSplit(string,"|")
    ; p(ar)
    if (rowsForSizes%whichSide%.Length()) {
        LV_Modify(rowsForSizes%whichSide%[1],,,,,,ar[2],ar[3])
            rowsForSizes%whichSide%.RemoveAt(1)
        }
    stuffByName%whichSide%[ar[1]]["size"]:=ar[3]
    
    ; if (name="MSIAfterburnerSetup")
    ; p(stuffByName["MSIAfterburnerSetup"])
    
}

WM_COPYDATA_READ(wp, lp)  {
    global
    ; global Script1Var,sortedBySize,canSortBySize,unsorted,stuffByName
    data := StrGet(NumGet(lp + A_PtrSize*2), "UTF-16")
    RegExMatch(data, "s)(.*)\|(\d+)", match)
    
    if (match2=1) {
        manageCMDArguments(match1)
    } else if (match2=2) {
        ; p(match1)
        receivedFolderSize(match1)
    } else if (match2=3) {
        sortedBySize%whichSide%:=sortArrayByArray(unsorted%whichSide%,stuffByName%whichSide%,true,"size")
        ; for k, v in sortedBySize%whichSide% {
        ; p(stuffByName%whichSide%[v])
        ; }
        ; p(sortedBySize)
        canSortBySize%whichSide%:=true
    }  else if (match2=4) {
        gosub, selectPanel%match1%
    } else if (match2=5) {
        gosub, copySelectedPaths
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
    global columnsToSort
    
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
    global
    selectedPaths:=[]
    for k, v in getSelectedNames() {
        selectedPaths.Push(EcurrentDir%whichSide% "\" v)
    }
return selectedPaths
}

doubleClickedNormal(ByRef index)
{
    global
    gui, main:default
    ControlFocus,, % "ahk_id " ListviewHwnd%whichSide%
    Gui, ListView, vlistView%whichSide%
    
    LV_GetText(filename,index,2)
    ; tooltip, % filename
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
    ControlFocus,, % "ahk_id " ListviewHwnd%whichSide%
}

stopSearching()
{
    global
    Gui, main:Default
    ControlFocus,, % "ahk_id " ListviewHwnd%whichSide%
    focused=flistView
    GuiControl,Text,currentDirEdit, % EcurrentDir%whichSide%
    searchString%whichSide%=
    renderCurrentDir()
}

HandleMessage( p_w, p_l, p_m, p_hw )
{
    global
    local control
    ; return
    ; p(p_w)
    if (!ignoreOut) {
        if (p_w=0x1000007) {
            ; p(p_l)
            whichSide:=1
            Gui, Show,NA,% EcurrentDir%whichSide% " - ahk_explorer"
            if (focused="flistView") ; if listView for instance
            {
                focused:="changePath"
            } else if (focused="listViewInSearch") {
                focused:="searchCurrentDirEdit"
            }
        }
        else if (p_w=0x100000B) {
            whichSide:=2
            Gui, Show,NA,% EcurrentDir%whichSide% " - ahk_explorer"
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
                Gui, Show,NA,% EcurrentDir%whichSide% " - ahk_explorer"
            }
            else if (p_w=0x200000B) {
                whichSide:=2
                Gui, Show,NA,% EcurrentDir%whichSide% " - ahk_explorer"
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
                        
                        focused:="flistView"
                        
                        MouseGetPos,,, OutputVarWin
                        GuiControl, Focus, vlistView%whichSide%
                        winactivate, ahk_id %OutputVarWin%
                        ; static EM_SETSEL   := 0x00B1
                        ; static EN_SETFOCUS := 0x0100
                        submitAndRenderDir()
                    }
                    else 
                    {
                        ; Gui, Submit, NoHide
                        ; currentDir:=currentDirEdit
                        ; 
                    }
                } else if ( p_l = RenameHwnd ) {
                    gosub, renameFileLabel
                }
            } 
        }
    }
    
}
return

searchInCurrentDir() {
    global
    if (searchString%whichSide%="") {
    } 
    else {
        searching:=true
        Gui, main:Default
        Gui, ListView, vlistView%whichSide%
        
        arrLength:=stuffByName.Length()
        ignoreOut:=true
        objectToSort:=[]
        namesForIcons%whichSide%:=[]
            
        GuiControl, -Redraw, vlistView%whichSide%
        LV_Delete()
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
            objectToSort:=ObjectSort(objectToSort,"pos")
            
            for k,v in objectToSort {
                name:=v["name"]
                obj:=stuffByName%whichSide%[name]
                calculateStuff(obj["date"],obj["attri"],obj["size"],name,k)
                
                LV_Add(,,name,var1,var2,formattedBytes,bytes)
                    LV_Colors.Cell(ListviewHwnd%whichSide%,k,3,color)
                namesForIcons%whichSide%.Push(name)
                }
        } else {
            searchFoldersOnly:=(searchString%whichSide%=".") ? true : false
            if (searchFoldersOnly) {
                counter:=0
                for k,v in sortedByDate%whichSide% {
                    if (counter>maxRows)
                        break
                    SplitPath, v,,, OutExtension
                    if (!OutExtension) {
                        obj:=stuffByName%whichSide%[v]
                        
                        calculateStuff(obj["date"],obj["attri"],obj["size"],v,k)
                        
                        LV_Add(,,v,var1,var2,formattedBytes,bytes)
                            LV_Colors.Cell(ListviewHwnd%whichSide%,k,3,color)
                        namesForIcons%whichSide%.Push(v)
                        }
                }
                
                
                ; for k,v in filesWithNoExt {
                ; ar:=EntriesNameNoExt[v]
                ; LV_Add(,ar["isFolder"],v,ar["date"],ar["sortableDate"],ar["size"],ar["sortableSize"])
                ; }
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
                objectToSort:=ObjectSort(objectToSort,"pos")
                for k,v in objectToSort {
                    name:=v["name"]
                    obj:=stuffByName%whichSide%[name]
                    
                    calculateStuff(obj["date"],obj["attri"],obj["size"],name,k)
                    
                    LV_Add(,,name,var1,var2,formattedBytes,bytes)
                        LV_Colors.Cell(ListviewHwnd%whichSide%,k,3,color)
                    namesForIcons%whichSide%.Push(name)
                    }
            }
            
        }
        GuiControl, +Redraw, vlistView%whichSide%
        applyIcons(namesForIcons%whichSide%)
        }
    
    loop % LV_GetCount() - 1 {
        
        LV_Modify(A_Index+1, "-Select -Focus") ; select
        }
    
    LV_Modify(1, "+Select +Focus Vis") ; select
        
    
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
renderCurrentDir()
{
    global
    lastChar:=SubStr(EcurrentDir%whichSide%, 0)
    if (lastChar="\")
        EcurrentDir%whichSide%:=SubStr(EcurrentDir%whichSide%, 1, StrLen(EcurrentDir%whichSide%)-1)
    Gui, ListView, vlistView%whichSide%
    
    ; LV_ModifyCol(2,50 AlignmentRight)
    ; GuiControl -NA, listView
    ; GuiControl, Focus, listView ;bad code
    
    currentDirSearch:=""
    if (InStr(fileExist(EcurrentDir%whichSide%), "D"))
    {
        stopSizes:=false
        
        if (lastDir%whichSide%!=EcurrentDir%whichSide% and !cannotDirHistory%whichSide%) {
            stopWatchFolder(EcurrentDir%whichSide%) 
            startWatchFolder(EcurrentDir%whichSide%)
            if (lastDir%whichSide%!="") {
                dirHistory%whichSide%.Push(lastDir%whichSide%)
            }
        }
        
        if cannotDirHistory%whichSide% {
            cannotDirHistory%whichSide%:=false
        }
        lastDir%whichSide%:=EcurrentDir%whichSide%
        focused=flistView
        
        
        
        filePaths:=[]  
        rowBak:=[]
        dates:=[]
        sortableDates:=[]
        sizes:=[]
        sortableSizes:=[]
        dateColors:=[]
        ; EntriesNameNoExt:={}
        filesWithNoExt:=[]
        if (lastIconNumber)
            rememberIconNumber:=lastIconNumber
        
        ; Entries := new Trie(500)
        ; ExtEntries := new Trie(500)
        unsorted%whichSide%:=[]
        sortedByDate%whichSide%:=[]
        sortedBySize%whichSide%:=[]
        canSortBySize%whichSide%:=false
        stuffByName%whichSide%:={}
        Loop, Files, % EcurrentDir%whichSide% "\*", DF
        {
            ; sortedByDate.Push({name:A_LoopFileName,date:A_LoopFileTimeAccessed,attri:A_LoopFileAttrib,size:A_LoopFileSize})
            stuffByName%whichSide%[A_LoopFileName]:={date:A_LoopFileTimeAccessed,attri:A_LoopFileAttrib,size:A_LoopFileSize}
                ; stuffByName[A_LoopFileName]:={date:A_LoopFileTimeAccessed,attri:A_LoopFileAttrib,size:A_LoopFileSize}
            ; fileNames.Push(A_LoopFileName)
            
        }
        for k in stuffByName%whichSide% {
            unsorted%whichSide%.Push(k)
        }
        
        ; count:=0
        ; for k, v in stuffByName {
        ; count++
        ; p(k)
        ; p(unsorted[count])
        ; }
        ; p(stuffByName)
        ; sortedByDate:=sortArrayByArray(unsorted,stuffByName,,"date")
        ; p(stuffByName%whichSide%)
        sortedByDate%whichSide%:=sortArrayByArray(unsorted%whichSide%,stuffByName%whichSide%,true,"date")
        ; for k, v in sortedByDate
        ; {
        ; p(stuffByName[v]["date"])
        ; }
        firstSizes%whichSide%:=true
        renderFunctionsToSort(sortedByDate%whichSide%)
        Gui, ListView, folderlistView2_%whichSide%
        LV_Delete()
        parent1DirDirs%whichSide%:=[]
        SplitPath, EcurrentDir%whichSide%, , parent1Dir%whichSide%
        SplitPath, parent1Dir%whichSide%, Out2DirName%whichSide% , parent2Dir%whichSide%,,,OutDrive2%whichSide%
        SplitPath, parent2Dir%whichSide%, Out3DirName%whichSide%, parent3Dir%whichSide%,,,OutDrive3%whichSide%
        Gui, Show,NA,% EcurrentDir%whichSide% " - ahk_explorer"
        
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
            LV_Modify(toSelect, "+Select +Focus Vis") ; select
            } else
        {
            LV_ModifyCol(1,"NoSort", "")
            } 
        Gui, ListView, folderlistView1_%whichSide%
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
            LV_Modify(toSelect, "+Select +Focus Vis") ; select
            }
        else
        {
            LV_ModifyCol(1,"NoSort", "")
            } 
        DriveGet, totalSpace, Capacity, C:
        DriveSpaceFree, freeSpace, C:
            GuiControl Text, DriveButton, % "C:\             " Round(100-100*freeSpace/totalSpace, 2)  "%`r`n" autoMegaByteFormat(freeSpace) "/" autoMegaByteFormat(totalSpace)
        } else {
            SplitPath, EcurrentDir%whichSide%, OutFileName%whichSide%, OutDir%whichSide%
            if (InStr(fileExist(OutDir%whichSide%), "D")) {
                toFocus:=OutFileName%whichSide%
                EcurrentDir%whichSide%:=OutDir%whichSide%
                
                renderCurrentDir()
                
            } else {
                ; p(fileExist(currentDir))
                EcurrentDir%whichSide%:=lastDir%whichSide%
                GuiControl, Text,vcurrentDirEdit%whichSide%, % EcurrentDir%whichSide%
                ; lastDir:=currentDir
            } 
            
            
        }
        Gui, ListView, vlistView%whichSide%
    }
    findNextDirNameNumberIteration(path)
    {
        global left
        global right
        SplitPath, path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
        getLeftRight(OutNameNoExt, "*")
        pathToCheck:=OutDir "\" left right
        incrementNumber:=2
        while (FileExist(pathToCheck)) {
            pathToCheck:=OutDir "\" left incrementNumber right
            incrementNumber++
        }
        return pathToCheck
    }
    
    getLeftRight(string, needle)
    {
        global left
        global right
        asteriskPos:=InStr(string, "*")
        left:=SubStr(string, 1, asteriskPos-1)
        right:=SubStr(string, asteriskPos+1)
    }
    
    ShellContextMenu(folderPath, files, win_hwnd = 0 )
    {
        if ( !folderPath  )
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
    DllCall(VTable(pIContextMenu, 3), "Ptr", pIContextMenu, "Ptr", hMenu, "Uint", 0, "Uint", 3, "Uint", 0x7FFF, "Uint", 0x100)   ;CMF_EXTENDEDVERBS
    ; p(hMenu)
    ComObjError(0)
    global pIContextMenu2 := ComObjQuery(pIContextMenu, IID_IContextMenu2:="{000214F4-0000-0000-C000-000000000046}")
    global pIContextMenu3 := ComObjQuery(pIContextMenu, IID_IContextMenu3:="{BCFCE0A0-EC17-11D0-8D10-00A0C90F2719}")
    e := A_LastError ;GetLastError()
    ComObjError(1)
    if (e != 0)
        goTo, StopContextMenu
    Global   WPOld:= DllCall("SetWindowLongPtr", "Ptr", win_hwnd, "int",-4, "Ptr",RegisterCallback("WindowProc"),"UPtr")
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
    struct_size  :=  16+11*A_PtrSize
    VarSetCapacity(pici,struct_size,0)
    NumPut(struct_size,pici,0,"Uint")         ;cbSize
    NumPut(0x4000|0x20000000|0x00100000,pici,4,"Uint")   ;fMask
    NumPut(win_hwnd,pici,8,"UPtr")       ;hwnd
    NumPut(1,pici,8+4*A_PtrSize,"Uint")       ;nShow
    NumPut(idn-3,pici,8+A_PtrSize,"UPtr")     ;lpVerb
    NumPut(idn-3,pici,16+6*A_PtrSize,"UPtr")  ;lpVerbW
    NumPut(pt,pici,16+10*A_PtrSize,"Uptr")    ;ptInvoke
    
    DllCall(VTable(pIContextMenu, 4), "Ptr", pIContextMenu, "Ptr", &pici)   ; InvokeCommand
    
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
    Global   pIContextMenu2, pIContextMenu3, WPOld
    If   pIContextMenu3
    {    ;IContextMenu3->HandleMenuMsg2
        If   !DllCall(VTable(pIContextMenu3, 7), "Ptr", pIContextMenu3, "Uint", nMsg, "Ptr", wParam, "Ptr", lParam, "Ptr*", lResult)
            Return   lResult
    }
    Else If   pIContextMenu2
    {    ;IContextMenu2->HandleMenuMsg
        If   !DllCall(VTable(pIContextMenu2, 6), "Ptr", pIContextMenu2, "Uint", nMsg, "Ptr", wParam, "Ptr", lParam)
            Return   0
    }
    Return   DllCall("user32.dll\CallWindowProcW", "Ptr", WPOld, "Ptr", hWnd, "Uint", nMsg, "Ptr", wParam, "Ptr", lParam)
}
VTable(ppv, idx)
{
    Return   NumGet(NumGet(1*ppv)+A_PtrSize*idx)
}
GUID4String(ByRef CLSID, String)
{
    VarSetCapacity(CLSID, 16,0)
    return DllCall("ole32\CLSIDFromString", "wstr", String, "Ptr", &CLSID) >= 0 ? &CLSID : ""
}
CoTaskMemFree(pv)
{
    Return   DllCall("ole32\CoTaskMemFree", "Ptr", pv)
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

sortArrayByArray(toSort, sortWith, reverse=false, key=false)
{
    global
    array:=[]
    finalAr:=[]
    if (key) {
        count:=0
        for k, v in sortWith {
            count++
            array.Push({1:v[key], 2:count})
        }
        array:=ObjectSort(array, 1,, reverse)
        for k in array {
            finalAr.Push(toSort[array[k][2]])
        }
    } else {
        for k in toSort {
            array.Push([toSort[k],sortWith[k]])
        }
        array:=ObjectSort(array, 2,,reverse)
        for k, v in array {
            finalAr.Push(v[1])
        }
    }
    return finalAr
}

;end of functions
;hotkeys
#if winactive("renamingWinTitle ahk_class AutoHotkeyGUI")
    $esc::
    if (focused="flistView")
    if (canRename) {
        canRename:=false
        gui, renameSimple:Default
        gui, submit
        gui, main:Default
        ControlFocus,, % "ahk_id " ListviewHwnd%whichSide%
        
        gui, renameSimple:Default
        gui, destroy
    }
    else
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

#if winactive("ahk_explorer ahk_class AutoHotkeyGUI")
^e::
; revealFileInExplorer(EcurrentDir%whichSide%, getSelectedNames())
path:=getSelectedPaths()[1]
if (path) {
    Run, % "explorer.exe /select,""" path """"
} else {
    Run, % "explorer.exe """ EcurrentDir%whichSide% """"
}
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
    Gui, Show,NA,% EcurrentDir%whichSide% " - ahk_explorer"
    GuiControl, Focus, vlistView1 ;bad code
    ControlFocus,, ahk_id %ListviewHwnd1%
    GuiControl, +Background%BGColorOfSelectedPane%, vlistView1
    GuiControl, +BackgroundWhite, vlistView2
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
    Gui, Show,NA,% EcurrentDir%whichSide% " - ahk_explorer"
    GuiControl, Focus, vlistView2 ;bad code
    ControlFocus,, ahk_id %ListviewHwnd2%
    GuiControl, +Background%BGColorOfSelectedPane%, vlistView2
    GuiControl, +BackgroundWhite, vlistView1
    EcurrentDir2:=EcurrentDir1
    renderCurrentDir()
return
left::
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
    Gui, Show,NA,% EcurrentDir%whichSide% " - ahk_explorer"
    GuiControl, Focus, vlistView1 ;bad code
    ControlFocus,, ahk_id %ListviewHwnd1%
    GuiControl, +Background%BGColorOfSelectedPane%, vlistView1
    GuiControl, +BackgroundWhite, vlistView2
return

right::
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
    Gui, Show,NA,% EcurrentDir%whichSide% " - ahk_explorer"
    GuiControl, Focus, vlistView2 ;bad code
    ControlFocus,, ahk_id %ListviewHwnd2%
    GuiControl, +Background%BGColorOfSelectedPane%, vlistView2
    GuiControl, +BackgroundWhite, vlistView1
    
return
$RCtrl::
    if (focused="searchCurrentDirEdit" or focused="flistView" or focused="listViewInSearch") {
        Run,"%ComSpec%", % EcurrentDir%whichSide%
    }
return
$RShift::
    if (focused="searchCurrentDirEdit" or focused="flistView" or focused="listViewInSearch") {
        toRun:= """" vscodePath """ """ EcurrentDir%whichSide% """"
        run, %toRun%
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
                toRun:= """" vscodePath """ """ v """"
                run, %toRun%
            }
        } 
    } else {
        send, \
    }
    
return

; tab::

return

; $`::
p(focused)
Return

$^+r::
    namesToMultiRename:=getSelectedNames()
    multiRenameDir:=EcurrentDir%whichSide%
    multiRenamelength:=namesToMultiRename.Length()
    Gui, multiRenameGui:Default
    Gui,Font, s10, Segoe UI
    
    Gui, Add, Edit, w400 vmultiRenameTheName
    Gui, Add, Edit, x+5 w300 vmultiRenameStartingNums 
    
    Gui, Add, Button, h30 w200 y+5 x+-705 ggmultiRenamePreview,preview
    Gui, Add, Button, h30 w200 x+5 ggmultiRenameApply,apply
    
    Gui, Add, ListBox, r%multiRenamelength% w500 y+5 vvmultiRenameTargets x+-405 , % array_ToVerticleBarString(selectedNames)
    Gui, Add, ListBox, r%multiRenamelength% w500 x+5 vvmultiRenamePreview,
    Gui, show,,multiRenameGui
return

$^r::
$esc::
    stopSearching()
return

$^+n::
    Gui, createFolder:Default
    
    creatingNewFolder:=true
    dontSearch:=true
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
        gui, createFolder: add, text,, Folder Name:  ; Save this control's position and start a new section.
        gui, createFolder: add, edit, w250 vcreateFolderName hwndfolderCreationHwnd, %newFolderName%
        gui, createFolder: add, button, Default w125 x11 vcreate gcreateLabel,Create Folder`r`n{Enter}
        gui, createFolder: add, button, w125 x+2 vcreateAndOpen gcreateAndOpenLabel,Create and Open`r`n{Shift + Enter}
    } else {
        ; GuiControl, text, createFolderName, %newFolderName%
        ControlSetText,, %newFolderName%, ahk_id %folderCreationHwnd%
        SendMessage, 0xB1, 0, -1,, % "ahk_id " folderCreationHwnd
        
    }
    
    gui, createFolder: show,, create_folder
    dontSearch:=false
    
return

copySelectedPaths:
^+c::
    Gui, main:Default
    ; Gui, ListView, listView
    ; GuiControlGet, FocusedControl, FocusV
    dontSearch:=true
    selectedNames:=getSelectedNames()
    finalStr=
    length:=selectedNames.Length()
    for k, v in selectedNames {
        if (k=length) {
            finalStr.=EcurrentDir%whichSide% "\" v
        }
        else {
            finalStr.=EcurrentDir%whichSide% "\" v "`r`n"
        }
    }
    clipboard:=finalStr
    dontSearch:=false
    
    #Persistent
    ToolTip, % length
    SetTimer, RemoveToolTip,-1000
return

return

$!left::
    Gui, main:Default
    SplitPath, % EcurrentDir%whichSide%,, ParentDir1
    EcurrentDir%whichSide%:=ParentDir1
    renderCurrentDir()
return

$!right::
    Gui, main:Default
    undoHistory%whichSide%.Push(EcurrentDir%whichSide%)
    EcurrentDir%whichSide%:=dirHistory%whichSide%[dirHistory%whichSide%.Length()]
    dirHistory%whichSide%.RemoveAt(dirHistory%whichSide%.Length())
    cannotDirHistory%whichSide%:=true
    renderCurrentDir()
return

$!up::
    Gui, main:Default
    EcurrentDir%whichSide%:=undoHistory%whichSide%[undoHistory%whichSide%.Length()]
    undoHistory%whichSide%.RemoveAt(undoHistory%whichSide%.Length())
    renderCurrentDir()
return

$^l::
$/::
    focused:="changePath"
    ControlFocus,, % "ahk_id " Edithwnd%whichSide%
    SendMessage, 177, 0, -1,, % "ahk_id " Edithwnd%whichSide%
return

$backspace::
    Gui, main:Default
    if (focused="changePath" or focused="renaming") {
        send, {backspace}
    } else if (focused="listViewInSearch" or focused="flistView") {
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
    
    ; if (selectedRow=0) {
    ; LV_Modify(numberOfRows, "+Select +Focus Vis") ; select
    ; }
    ; else 
    if (selectedRow<2) {
        LV_Modify(numberOfRows, "+Select +Focus Vis") ; select
        }
    else {
        LV_Modify(selectedRow-1, "+Select +Focus Vis") ; select
        }
return
$+home::
    Gui, main:Default
    Gui, ListView, vlistView%whichSide%
    selectedRow:=LV_GetNext()
    loop % selectedRow - 1 {
        LV_Modify(A_Index, "+Select +Focus Vis") ; select
        }
    
return
$+end::
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
    SetTimer, downLabel ,-0
return
downLabel:
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
    ; } else {
    ; p(6556)
    ; send, {down}
    ; }
return
;how to fix $enter not working ? why ?
;sign out and sign in fixed it
$enter::
    Gui, main:Default
    if (focused="flistView" or focused="searchCurrentDirEdit" or focused="listViewInSearch") {
        stopSizes:=false
        gui, ListView, vlistView%whichSide%
        row:=LV_GetNext("")
        doubleClickedNormal(row)
        ControlFocus,, % "ahk_id " ListviewHwnd%whichSide%
    }  else if (focused="changePath" or focused="renaming") {
        ControlFocus,, % "ahk_id " ListviewHwnd%whichSide%
    }
return

