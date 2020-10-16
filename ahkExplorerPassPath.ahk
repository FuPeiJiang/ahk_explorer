#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, force
    SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetTitleMatchMode, 2

OnExit, OnExit

TaskName := RunAsTask()                           ; This function will never return on the first run
FileRead, CmdLine, %A_Temp%\%A_ScriptName%.tmp 
If ( CmdLine = "" )                               ; Script/shortcut was launched with another admin app  
    CmdLine := DllCall( "GetCommandLine","Str" ) ; or with context menu item "Run as Administrator" !!!

Loop % ( A_IsCompiled ? 1 : 2 )      ; Excludes 'AutoHotkey exe' and 'Script path' from the command line 
    CmdLine := DllCall( "shlwapi\PathGetArgs", "Str",CmdLine, "Str" )

if (CmdLine) {
    if (SubStr(CmdLine, 1 , 1)!="""")
    p("WTH IS GOING ON")

    pos:=InStr(CmdLine, """" ,, 2)

    unQuoted:=SubStr(CmdLine, 2 , pos-2)


    if WinExist("ahk_explorer ahk_class AutoHotkeyGUI") and unQuoted
    {
        send_string(unQuoted)
    }
    else
    {
        lol="%A_AhkPath%" "%A_ScriptFullPath%\..\ahk_explorer.ahk" "%unQuoted%"
        run, %lol%
    }
    
} else {
    run, "%A_AhkPath%" ""%A_ScriptFullPath%\..\ahk_explorer.ahk""
}

ExitApp

OnExit:
    IfNotEqual, A_ExitReason, Reload, FileDelete, %A_Temp%\%A_ScriptName%.tmp
        IfEqual, TaskName,, FileAppend, % DllCall( "GetCommandLine","Str" ), %A_Temp%\%A_ScriptName%.tmp, UTF-8
        ExitApp
    
    
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
    
    RunAsTask() { ; By SKAN, http://goo.gl/yG6A1F, CD:19/Aug/2014 | MD:24/Apr/2020
        
        Local CmdLine, TaskName, TaskExists, XML, TaskSchd, TaskRoot, RunAsTask
        Local TASK_CREATE := 0x2, TASK_LOGON_INTERACTIVE_TOKEN := 3 
        
        Try TaskSchd := ComObjCreate( "Schedule.Service" ), TaskSchd.Connect()
        , TaskRoot := TaskSchd.GetFolder( "\" )
        Catch
        Return "", ErrorLevel := 1 
        
        CmdLine := ( A_IsCompiled ? "" : """" A_AhkPath """" ) A_Space ( """" A_ScriptFullpath """" )
        TaskName := "[RunAsTask] " A_ScriptName " @" SubStr( "000000000" DllCall( "NTDLL\RtlComputeCrc32"
        , "Int",0, "WStr",CmdLine, "UInt",StrLen( CmdLine ) * 2, "UInt" ), -9 )
        
        Try RunAsTask := TaskRoot.GetTask( TaskName )
        TaskExists := ! A_LastError 
        
        
        If ( not A_IsAdmin and TaskExists ) { 
            
            RunAsTask.Run( "" )
            ExitApp
            
        }
        
        If ( not A_IsAdmin and not TaskExists ) { 
            
            Run *RunAs %CmdLine%, %A_ScriptDir%, UseErrorLevel
            ExitApp
            
        }
        
        If ( A_IsAdmin and not TaskExists ) { 
            
            XML := "
            ( LTrim Join
            <?xml version=""1.0"" ?><Task xmlns=""http://schemas.microsoft.com/windows/2004/02/mit/task""><Regi
            strationInfo /><Triggers /><Principals><Principal id=""Author""><LogonType>InteractiveToken</LogonT
            ype><RunLevel>HighestAvailable</RunLevel></Principal></Principals><Settings><MultipleInstancesPolic
            y>Parallel</MultipleInstancesPolicy><DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries><
                StopIfGoingOnBatteries>false</StopIfGoingOnBatteries><AllowHardTerminate>false</AllowHardTerminate>
                <StartWhenAvailable>false</StartWhenAvailable><RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAva
                ilable><IdleSettings><StopOnIdleEnd>true</StopOnIdleEnd><RestartOnIdle>false</RestartOnIdle></IdleS
            ettings><AllowStartOnDemand>true</AllowStartOnDemand><Enabled>true</Enabled><Hidden>false</Hidden><
            RunOnlyIfIdle>false</RunOnlyIfIdle><DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteApp
                Session><UseUnifiedSchedulingEngine>false</UseUnifiedSchedulingEngine><WakeToRun>false</WakeToRun><
                ExecutionTimeLimit>PT0S</ExecutionTimeLimit></Settings><Actions Context=""Author""><Exec>
            <Command>""" ( A_IsCompiled ? A_ScriptFullpath : A_AhkPath ) """</Command>
            <Arguments>" ( !A_IsCompiled ? """" A_ScriptFullpath """" : "" ) "</Arguments>
            <WorkingDirectory>" A_ScriptDir "</WorkingDirectory></Exec></Actions></Task>
            )" 
            
            TaskRoot.RegisterTask( TaskName, XML, TASK_CREATE, "", "", TASK_LOGON_INTERACTIVE_TOKEN )
            
        } 
        
        Return TaskName, ErrorLevel := 0
    } ; _____________________________________________________________________________________________________
    Args( CmdLine := "", Skip := 0 ) 
    {     ; By SKAN,  http://goo.gl/JfMNpN,  CD:23/Aug/2014 | MD:24/Aug/2014
        Local pArgs := 0, nArgs := 0, A := []
        
        pArgs := DllCall( "Shell32\CommandLineToArgvW", "WStr",CmdLine, "PtrP",nArgs, "Ptr" ) 
        
        Loop % ( nArgs ) 
            If ( A_Index > Skip ) 
            A[ A_Index - Skip ] := StrGet( NumGet( ( A_Index - 1 ) * A_PtrSize + pArgs ), "UTF-16" )  
        
        Return A,   A[0] := nArgs - Skip,   DllCall( "LocalFree", "Ptr",pArgs )  
    }
    
    f3::Exitapp
    
    