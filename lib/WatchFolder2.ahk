; https://www.autohotkey.com/boards/viewtopic.php?t=8384
; ==================================================================================================================================
; Function:       Notifies about changes within folders.
;                 This is a rewrite of HotKeyIt's WatchDirectory() released at
;                    http://www.autohotkey.com/board/topic/60125-ahk-lv2-watchdirectory-report-directory-changes/
; Tested with:    AHK 1.1.23.01 (A32/U32/U64)
; Tested on:      Win 10 Pro x64
; Usage:          WatchFolder(Folder, UserFunc[, SubTree := False[, Watch := 3]])
; Parameters:
;     Folder      -  The full qualified path of the folder to be watched.
;                    Pass the string "**PAUSE" and set UserFunc to either True or False to pause respectively resume watching.
;                    Pass the string "**END" and an arbitrary value in UserFunc to completely stop watching anytime.
;                    If not, it will be done internally on exit.
;     UserFunc    -  The name of a user-defined function to call on changes. The function must accept at least two parameters:
;                    1: The path of the affected folder. The final backslash is not included even if it is a drive's root
;                       directory (e.g. C:).
;                    2: An array of change notifications containing the following keys:
;                       Action:  One of the integer values specified as FILE_ACTION_... (see below).
;                                In case of renaming Action is set to FILE_ACTION_RENAMED (4).
;                       Name:    The full path of the changed file or folder.
;                       OldName: The previous path in case of renaming, otherwise not used.
;                       IsDir:   True if Name is a directory; otherwise False. In case of Action 2 (removed) IsDir is always False.
;                    Pass the string "**DEL" to remove the directory from the list of watched folders.
;     SubTree     -  Set to true if you want the whole subtree to be watched (i.e. the contents of all sub-folders).
;                    Default: False - sub-folders aren't watched.
;     Watch       -  The kind of changes to watch for. This can be one or any combination of the FILE_NOTIFY_CHANGES_...
;                    values specified below.
;                    Default: 0x03 - FILE_NOTIFY_CHANGE_FILE_NAME + FILE_NOTIFY_CHANGE_DIR_NAME
; Return values:
;     Returns True on success; otherwise False.
; Change history:
;     1.0.03.00/2021-10-14/just me        -  bug-fix for addding, removing, or updating folders.
;     1.0.02.00/2016-11-30/just me        -  bug-fix for closing handles with the '**END' option.
;     1.0.01.00/2016-03-14/just me        -  bug-fix for multiple folders
;     1.0.00.00/2015-06-21/just me        -  initial release
; License:
;     The Unlicense -> http://unlicense.org/
; Remarks:
;     Due to the limits of the API function WaitForMultipleObjects() you cannot watch more than this.MAXIMUM_WAIT_OBJECTS (64)
;     folders simultaneously.
; MSDN:
;     ReadDirectoryChangesW          msdn.microsoft.com/en-us/library/aa365465(v=vs.85).aspx
;     FILE_NOTIFY_CHANGE_FILE_NAME   = 1   (0x00000001) : Notify about renaming, creating, or deleting a file.
;     FILE_NOTIFY_CHANGE_DIR_NAME    = 2   (0x00000002) : Notify about creating or deleting a directory.
;     FILE_NOTIFY_CHANGE_ATTRIBUTES  = 4   (0x00000004) : Notify about attribute changes.
;     FILE_NOTIFY_CHANGE_SIZE        = 8   (0x00000008) : Notify about any file-size change.
;     FILE_NOTIFY_CHANGE_LAST_WRITE  = 16  (0x00000010) : Notify about any change to the last write-time of files.
;     FILE_NOTIFY_CHANGE_LAST_ACCESS = 32  (0x00000020) : Notify about any change to the last access time of files.
;     FILE_NOTIFY_CHANGE_CREATION    = 64  (0x00000040) : Notify about any change to the creation time of files.
;     FILE_NOTIFY_CHANGE_SECURITY    = 256 (0x00000100) : Notify about any security-descriptor change.
;     FILE_NOTIFY_INFORMATION        msdn.microsoft.com/en-us/library/aa364391(v=vs.85).aspx
;     FILE_ACTION_ADDED              = 1   (0x00000001) : The file was added to the directory.
;     FILE_ACTION_REMOVED            = 2   (0x00000002) : The file was removed from the directory.
;     FILE_ACTION_MODIFIED           = 3   (0x00000003) : The file was modified.
;     FILE_ACTION_RENAMED            = 4   (0x00000004) : The file was renamed (not defined by Microsoft).
;     FILE_ACTION_RENAMED_OLD_NAME   = 4   (0x00000004) : The file was renamed and this is the old name.
;     FILE_ACTION_RENAMED_NEW_NAME   = 5   (0x00000005) : The file was renamed and this is the new name.
;     GetOverlappedResult            msdn.microsoft.com/en-us/library/ms683209(v=vs.85).aspx
;     CreateFile                     msdn.microsoft.com/en-us/library/aa363858(v=vs.85).aspx
;     FILE_FLAG_BACKUP_SEMANTICS     = 0x02000000
;     FILE_FLAG_OVERLAPPED           = 0x40000000
; ==================================================================================================================================
class WatchFolder {
   Static MAXIMUM_WAIT_OBJECTS := 64
   Static MAX_DIR_PATH := 260 - 12 + 1

   Static SizeOfLongPath := this.MAX_DIR_PATH << !!A_IsUnicode
   Static SizeOfFNI := 0xFFFF ; size of the FILE_NOTIFY_INFORMATION structure buffer (64 KB)
   Static SizeOfOVL := 32 ; size of the OVERLAPPED structure (64-bit)

   Static timerFunc := ObjBindMethod(WatchFolder, "_Tick") ;https://www.autohotkey.com/docs/commands/SetTimer.htm#ExampleClass

   Static FolderToEvent := {}
   ; {
   ; ["C:\Users\Public\AHK\notes\tests"]:596,
   ; [Folder]:EventHandle,
   ; }
   Static EventToFolderinfo := {}
   ; {
   ; 596:{"FNIAddr":48942944, "FNIBuff":"", "Func":[], "Handle":608, "Name":"C:\Users\Public\AHK\notes\tests", "OVLAddr":50479504, "OVLBuff":"ă", "SubTree":0, "Watch":3}
   ; [EventHandle]: {Handle:from CreateFile, ...},
   ; }
   Static EventToFolderinfo_Count := 0
   Static WaitObjectsPtr := 0
   Static Paused := False

   ; --- Static Methods ---
   Add(Folder, UserFunc, SubTree := False, Watch := 0x03) {
      ; ===============================================================================================================================
      Folder := this._SanitizeUserInput(Folder)
      if (Folder==False) {
         return
      }

      ; if it's already watching, remove it first
      this._Remove(Folder)

      If (this.EventToFolderinfo_Count < this.MAXIMUM_WAIT_OBJECTS) { ; add
         If (IsFunc(UserFunc) && (UserFunc := Func(UserFunc)) && (UserFunc.MinParams >= 2)) && (Watch &= 0x017F) {
            Handle := DllCall("CreateFile", "Str", Folder . "\", "UInt", 0x01, "UInt", 0x07, "Ptr",0, "UInt", 0x03
            , "UInt", 0x42000000, "Ptr", 0, "UPtr")
            If (Handle > 0) {
               Event := DllCall("CreateEvent", "Ptr", 0, "Int", 1, "Int", 0, "Ptr", 0)
               FolderObj := {Name: Folder, Func: UserFunc, Handle: Handle, SubTree: !!SubTree, Watch: Watch}
               FolderObj.SetCapacity("FNIBuff", this.SizeOfFNI)
               FNIAddr := FolderObj.GetAddress("FNIBuff")
               DllCall("RtlZeroMemory", "Ptr", FNIAddr, "Ptr", this.SizeOfFNI)
               FolderObj["FNIAddr"] := FNIAddr
               FolderObj.SetCapacity("OVLBuff", this.SizeOfOVL)
               OVLAddr := FolderObj.GetAddress("OVLBuff")
               DllCall("RtlZeroMemory", "Ptr", OVLAddr, "Ptr", this.SizeOfOVL)
               NumPut(Event, OVLAddr + 8, A_PtrSize * 2, "Ptr")
               FolderObj["OVLAddr"] := OVLAddr
               DllCall("ReadDirectoryChangesW", "Ptr", Handle, "Ptr", FNIAddr, "UInt", this.SizeOfFNI, "Int", SubTree
               , "UInt", Watch, "UInt", 0, "Ptr", OVLAddr, "Ptr", 0)
               this.EventToFolderinfo[Event] := FolderObj
               this.EventToFolderinfo_Count++
               this.FolderToEvent[Folder] := Event
               this._RebuildWaitObjects()
            }
         }
      }

      ; ===============================================================================================================================
      If (this.EventToFolderinfo_Count > 0) {
         timerFunc:=this.timerFunc
         SetTimer, % timerFunc, -100
      }
      ; Return (RebuildWaitObjects) ; returns True on success, otherwise False
   }

   Pause() {
      this.Paused:=true
   }
   UnPause() { ;Resume is too easily mistaken as Remove
      this.Paused:=false
   }

   Remove(Folder) {
      Folder := this._SanitizeUserInput(Folder)
      if (Folder==False) {
         return
      }
      this._Remove(Folder)
      this._RebuildWaitObjects()
   }
   _Remove(Folder) {
      If (this.FolderToEvent.HasKey(Folder)) { ; update or remove
         Event := this.FolderToEvent[Folder]
         FolderObj := this.EventToFolderinfo[Event]
         DllCall("CloseHandle", "Ptr", FolderObj.Handle)
         DllCall("CloseHandle", "Ptr", Event)
         this.EventToFolderinfo.Delete(Event)
         this.EventToFolderinfo_Count--
         this.FolderToEvent.Delete(Folder)
      }
   }
   _RebuildWaitObjects() {
      ; https://www.autohotkey.com/boards/viewtopic.php?f=5&t=4384#p24452

      DllCall( "GlobalFree", "Ptr",this.WaitObjectsPtr )
      ; thanks to "just me" https://www.autohotkey.com/boards/viewtopic.php?p=425240#p425240
      ; GMEM_ZEROINIT
      ; 0x0040
      ; Initializes memory contents to zero.
      this.WaitObjectsPtr := DllCall( "GlobalAlloc", "UInt",0x40, "UInt",this.MAXIMUM_WAIT_OBJECTS * A_PtrSize, "Ptr")
      ; The movable-memory flags GHND and GMEM_MOVABLE add unnecessary overhead and require locking to be used safely. They should be avoided unless documentation specifically states that they should be used.
      ; https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-globalalloc#remarks
      ; GHND
      ; 0x0042
      ; Combines GMEM_MOVEABLE and GMEM_ZEROINIT.

      OffSet := this.WaitObjectsPtr
      For Event In this.EventToFolderinfo
         Offset := NumPut(Event, Offset + 0, 0, "Ptr")
   }

   _SanitizeUserInput(Folder) {
      If (Folder == "")
         Return False
      return this._getLongPath(Folder)
   }
   _getLongPath(Folder) {
      Static MAX_DIR_PATH := 260 - 12 + 1
      Static SizeOfLongPath := MAX_DIR_PATH << !!A_IsUnicode

      Folder := RTrim(Folder, "\")
      VarSetCapacity(LongPath, SizeOfLongPath, 0)
      If !DllCall("GetLongPathName", "Str", Folder, "Ptr", &LongPath, "UInt", MAX_DIR_PATH)
         return False
      VarSetCapacity(LongPath, -1)
      return LongPath
   }

   RemoveAll(Folder) {
      For Event, Folder In this.EventToFolderinfo {
         DllCall("CloseHandle", "Ptr", Folder.Handle)
         DllCall("CloseHandle", "Ptr", Event)
      }
      this.FolderToEvent := {}
      this.EventToFolderinfo := {}
      this.EventToFolderinfo_Count := 0
      this.Paused := False
      Return True
   }

   _Tick() {
      If (this.EventToFolderinfo_Count > 0) {
         if (!this.Paused) {
            ObjIndex := DllCall("WaitForMultipleObjects", "UInt", this.EventToFolderinfo_Count, "Ptr", this.WaitObjectsPtr, "Int", 0, "UInt", 0, "UInt")
            While (ObjIndex >= 0) && (ObjIndex < this.EventToFolderinfo_Count) {
               Event := NumGet(this.WaitObjectsPtr+0, ObjIndex * A_PtrSize, "UPtr")
               Folder := this.EventToFolderinfo[Event]
               If DllCall("GetOverlappedResult", "Ptr", Folder.Handle, "Ptr", Folder.OVLAddr, "UInt*", BytesRead, "Int", True) {
                  Changes := []
                  FNIAddr := Folder.FNIAddr
                  FNIMax := FNIAddr + BytesRead
                  OffSet := 0
                  PrevIndex := 0
                  PrevAction := 0
                  PrevName := ""
                  Loop {
                     FNIAddr += Offset
                     OffSet := NumGet(FNIAddr + 0, "UInt")
                     Action := NumGet(FNIAddr + 4, "UInt")
                     Length := NumGet(FNIAddr + 8, "UInt") // 2
                     Name := Folder.Name . "\" . StrGet(FNIAddr + 12, Length, "UTF-16")
                     IsDir := InStr(FileExist(Name), "D") ? 1 : 0
                     If (Name = PrevName) {
                        If (Action = PrevAction)
                           Continue
                        If (Action = 1) && (PrevAction = 2) {
                           PrevAction := Action
                           Changes.RemoveAt(PrevIndex--)
                           Continue
                        }
                     }
                     If (Action = 4)
                        PrevIndex := Changes.Push({Action: Action, OldName: Name, IsDir: 0})
                     Else If (Action = 5) && (PrevAction = 4) {
                        Changes[PrevIndex, "Name"] := Name
                        Changes[PrevIndex, "IsDir"] := IsDir
                     }
                     Else
                        PrevIndex := Changes.Push({Action: Action, Name: Name, IsDir: IsDir})
                     PrevAction := Action
                     PrevName := Name
                  } Until (Offset = 0) || ((FNIAddr + Offset) > FNIMax)
                  If (Changes.Length() > 0)
                     Folder.Func.Call(Folder.Name, Changes)
                  DllCall("ResetEvent", "Ptr", Event)
                  DllCall("ReadDirectoryChangesW", "Ptr", Folder.Handle, "Ptr", Folder.FNIAddr, "UInt", this.SizeOfFNI
                  , "Int", Folder.SubTree, "UInt", Folder.Watch, "UInt", 0
                  , "Ptr", Folder.OVLAddr, "Ptr", 0)
               }
               ObjIndex := DllCall("WaitForMultipleObjects", "UInt", this.EventToFolderinfo_Count, "Ptr", this.WaitObjectsPtr, "Int", 0, "UInt", 0, "UInt")
               Sleep, 0
            }
         }

         timerFunc:=this.timerFunc
         SetTimer, % timerFunc, -100
      } ;end If (this.EventToFolderinfo_Count > 0) {

   }

}