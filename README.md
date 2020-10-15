## much fast file manager

You have to put ahk_explorer_settings in %Appdata% with :\
vscodePath.txt\
peazipPath.txt\
favoriteFolders.txt\
BGColorOfSelectedPane.txt

just type, to start searching for the file you want, (case insensitive and ignores file extensions)\
If I wanted to search for "ahk_explorer.ahk" I would type "ex"\
type . to search for files\folders with no extensions\
type .txt to search for .txt files

esc : refresh page, or stop searching

ctrl+shift+left : panel : left <- right\
ctrl+shift+right : panel : left -> right

ctrl+left\
ctrl+1 : select left panel

ctrl+left\
ctrl+2 : select right panel

you can use these to get out of search.

/ : change Dir\
ctrl+L : change Dir

alt+left : go to parent Dir\
alt+right : undo Dir change\
alt+up : redo the undo

RCtrl : open CMD at currentDir\
RShift : open vscode at currentDir\
\ : open selected files\folders in vscode

ctrl+shift+c : get fullPath of selected files

ctrl+shift+x : extract selected files using 
7-Zip\
ctrl+shift+d : archive selected files using PeaZip

you can change the hotkeys to what you want

up, down to navigate\
there is shift+up, shift+down, ctrl+up, ctrl+down\
shift can be used to retract, ctrl will never retract, it will overflow to other side. for example : after shift+down, two (rows) will be selected, if I do shift+up, only one will be selected, but if I did ctrl+up instead, 3 will be selected.

enter : enter Dir or run the file

it uses LastAccessDate for dates, so its inconsistent, but it works better for me.\
I can add a setting in %Appdata% if you want to switch to LastModifyDate

feedback and suggestions are much appreciated!