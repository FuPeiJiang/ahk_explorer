## much fast folder navigator for hotkeys
## Features: most used to least used

* start typing to search for file (case insensitive)\
(to search for `ahk_explorer.ahk` I would type `ex`)
* <kbd>Esc</kbd> refresh page, or stop searching
* <kbd>Up</kbd>, <kbd>Down</kbd> works even when selection is grey or when searching
* <kbd>Enter</kbd> go in folder | run file(s)
* <kbd>BackSpace</kbd> go to parent folder

<br>

* <kbd>Win</kbd>+<kbd>E</kbd> will bring up (WinActivate) ahk_explorer, EVEN if you are in another virtual desktop 

<br>

* hotkey to open folder: see **[hotkey open folder.ahk](hotkey%20open%20folder.ahk)**: I use <kbd>Win</kbd>+<kbd>Shift</kbd>+<kbd>D</kbd> to open `C:\Users\User\Downloads` and <kbd>Win</kbd>+<kbd>1</kbd> to open `C:\Users\Public\AHK`

<br>

* Favorite folders on the left, <kbd>DoubleClick</kbd> to open
* <kbd>Click</kbd> on Favorites to edit your favorite folders using [vscode](#to-open-default-apps,-Fill-in-the-settings-you-need)

<br>

* RShift=Shift on the right of your keyboard
* <kbd>RShift</kbd> open current folder using [vscode](#to-open-default-apps,-Fill-in-the-settings-you-need)
* <kbd>\\</kbd> open selected file(s) using [vscode](#to-open-default-apps,-Fill-in-the-settings-you-need)
* <kbd>RCtrl</kbd> open `cmd.exe` at current folder, <kbd>RAlt</kbd> powershell.exe

<br>

* <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>C</kbd> : copy longPaths of selected files (newline separated)
* <kbd>/</kbd> OR <kbd>Ctrl</kbd>+<kbd>L</kbd>: change folder


supports:
- file path: the file will be selected, not opened/ran
- unix path: turns `/` to `\` 
- url path: `file:///C:/%C3%A9`


ctrl+shift+x : extract selected files using 
7-Zip\
ctrl+shift+d : archive selected files using PeaZip

type `.` to search for files|folders with no extensions\
type `.txt` to search for `.txt` files

ctrl+e : open current folder in Explorer.exe

### it's DUAL PANE, you also see up to 2 parent folders on top (see [One Commander](https://www.onecommander.com/))

left\
ctrl+left\
ctrl+1 : select left panel

right\
ctrl+right\
ctrl+2 : select right panel


alt+left : go to parent Dir\
alt+right : undo Dir change\
alt+up : redo the undo


ctrl+shift+left : panel : left <- right\
ctrl+shift+right : panel : left -> right
___

you can change the hotkeys to what you want: in **[ahk_explorer.ahk](ahk_explorer.ahk)**, search for `;hotkeys`, that's where hotkeys start.
___

it uses `LastAccessDate` for dates, so its inconsistent, but it works better for me.\
I can add a setting in `%Appdata%` if you want to switch to `LastModifyDate`

feedback and suggestions are much appreciated!\
(There's now `Discussions` if issue is too "formal")

## download and use

* git clone using [GitHub Desktop](https://desktop.github.com)
* run [ahk_explorer.ahk](ahk_explorer.ahk) (I suggest making a hotkey like <kbd>Win</kbd> + <kbd>e</kbd> to run this)

pull origin to update!

you need [AutoHotkey_L](https://www.autohotkey.com/download) to run it

## to open default apps, Fill in the settings you need
settings are in `%appdata%\ahk_explorer_settings\settings.txt`\
but you can click `settings` button (top-left) to edit them
![](https://i.imgur.com/L5uzx8Y.png)

### sometimes it will FREEZE, but I don't think it's random

I need help on this: https://github.com/FuPeiJiang/ahk_explorer/issues/5

currently what I do:
* **close the app:** 
  - <kbd>Alt</kbd>+<kbd>F4</kbd>
  - <kbd>Shift</kbd>+<kbd>Click</kbd> the `X` top right
* **use a hotkey to restart the app** (I use <kbd>Win</kbd>+<kbd>E</kbd>)

clicking on `X` without shift will `Gui, hide` the app but not terminate it.



