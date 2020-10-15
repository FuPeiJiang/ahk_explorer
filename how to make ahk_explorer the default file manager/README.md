you can use the .reg if your ahk_explorer.ahk is located in C:\Users\User\Documents\GitHub\ahk_explorer\

if not you'll have to replace that with your location in 

[HKEY_CLASSES_ROOT\Directory\shell\ahk\command]

replace (default) with 

"A_AhkPath" "ahk_explorerPath" "%1"

replace A_AhkPath with the fullpath of your Autohotkey.exe

replace ahk_explorerPath with the fullpath of your ahk_explorer.ahk