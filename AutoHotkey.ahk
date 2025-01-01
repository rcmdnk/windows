#Requires AutoHotkey v2.0
; Tips {{{
; #: win
; !: alt
; ^: ctrl
; +: shift
; &: and
; <: only left, >: only right
; *: wildecard
; ~: pass through
; }}}

; Auto execute section is the region before any return/hotkey {{{
; Windows size
TMargin := 5
BMargin := 5
LMargin := 5
RMargin := 5 ; sidebar = 150px
MinSize := 0.7
MouseMoveSize := 10
MouseWheelSize := 2
WinMoveSize := 20
WinResizeSize := 20

InstallKeybdHook(true) ; For checking key history
                       ; Use ~500kB memory?
A_HotkeyInterval := 1000 ; Hotkey inteval (default 2000 milliseconds).
A_MaxHotkeysPerInterval := 100 ; Max hotkeys perinterval (default 50).

; ToggleApp
LaunchApp(winName, appPath) {
    Run(appPath)
    WinWait(winName)
    WinActivate(winName)
}

prevApp(winName) {
    Send("!{Tab}")
    Send("{Alt Up}")
}

ToggleApp(key, winName, appPath) {
    HotIfWinActive(winName)
    Hotkey(key, (*) => prevApp(winName))
    HotIfWinExist(winName)
    Hotkey(key, (*) => WinActivate(winName))
    HotIf
    Hotkey(key, (*) => LaunchApp(winName, appPath))
    HotIf
}

obsidian_app := "C:\Users\" A_UserName "\AppData\Local\obsidian\Obsidian.exe"

ToggleApp("^!c", "ahk_exe chrome.exe", A_ProgramFiles "\Google\Chrome\Application\chrome.exe")
ToggleApp("^!s", "ahk_exe slack.exe", A_ProgramFiles "\Slack\Slack.exe")
ToggleApp("^!t", "ahk_exe Hyper.exe", "C:\Users\" A_UserName "\AppData\Local\Programs\Hyper.exe")
ToggleApp("^!q", "ahk_exe Obsidian.exe", obsidian_app)

; For Terminal/Vim
GroupAdd "Terminal", "ahk_class PuTTY"
GroupAdd "Terminal", "ahk_class mintty" ; cygwin
GroupAdd "Terminal", "ahk_class TMobaXtermForm"
GroupAdd "Terminal", "ahk_class TFormDetachedTab"
GroupAdd "Terminal", "ahk_class ConsoleWindowClass"
GroupAdd "Terminal", "ahk_exe WindowsTerminal.exe"
GroupAdd "Terminal", "ahk_exe powershell.exe"
GroupAdd "Terminal", "ahk_exe Hyper.exe"
GroupAdd "Terminal", "ahk_exe vim.exe"
GroupAdd "TerminalVim", "ahk_group Terminal"
GroupAdd "TerminalVim", "ahk_class Vim"
GroupAdd "TerminalVim", "ahk_class mintty"
GroupAdd "TerminalVim", "ahk_class CASCADIA_HOSTING_WINDOW_CLASS"
GroupAdd "TerminalVim", "ahk_exe WindowsTerminal.exe"

; For browsers
GroupAdd "Browser", "ahk_exe chrome.exe"
GroupAdd "Browser", "ahk_exe firefox.exe"
GroupAdd "Browser", "ahk_exe msedge.exe"

; External files (Only 1 file, at last of Auto execute section"
#Include %A_LineFile%\..\submodules\vim_ahk\vim.ahk

Return
; }}}

; External files w/o Auto execute section
#Include %A_LineFile%\..\AutoCorrect.ahk

;; Basic Settings, HotKeys, Functions {{{
; Settings

#UseHook True ; Make it a bit slow, but can avoid infinitude loop
              ; Same as "$" for each hotkey
; For HHKB
;vkFFsc079::RCtrl
;vkFFsc07b::LCtrl
; }}}

; Terminal/Vim {{{
; ESC + IME
#HotIf WinActive("ahk_group TerminalVim")
; Use ESC as ` or ESC with long push, especially for HHKB
;Esc:: ; Just send Esc at converting.
;{
;  if(VIM_IME_GET("A")){
;    if(VIM_IME_GetConverting("A")){
;      Send "{Esc}"
;    }else{
;      VIM_IME_SET()
;    }
;  }else{
;    Send "{Esc}"
;  }
;}

^[:: ; Go to Normal mode (for vim) with IME off even at converting.
{
  if(VIM_IME_GetConverting("A")){
    SendInput "{Esc}"
    Sleep(1) ; wait 1 ms (Need to stop converting)
    VIM_IME_SET()
    SendInput "{Esc}"
  }else if(VIM_IME_GET("A")){
    VIM_IME_SET()
    SendInput "{Esc}"
  }else{
    SendInput "{Esc}"
  }
}

^m::SendInput "^m" ; Use Ctrl-m as is

; Paste
#HotIf WinActive("ahk_group Terminal")
!v::
{
  ;StringSplit, strout, clipboard, `n
  ;If(strout0>1 or InStr(clipboard, "sudo")>0){
  ;  MsgBox, 308, Clipboard, %clipboard%`n`n Do you want to paste?
  ;  IfMsgBox, No
  ;  {
  ;    Return
  ;  }
  ;}
  ;SendInput %clipboard%
  Sleep(200)
  MouseClick "Right", 50, 50, 1
}

#HotIf WinActive("ahk_class Vim")
!v::SendInput "{Alt}ep"

; Other than Terminal/Vim
#HotIf not WinActive("ahk_group TerminalVim")
^[::SendInput "{Esc}"             ; Always C-[ to ESC, like vim
^d::SendInput "{Del}"             ; Always Delete with C-d
; }}} Terminal/Vim

; Power Point {{{
#HotIf WinActive("ahk_class PP12FrameClass")
; Subscript/Superscript
^=::SendInput "^tb{Enter}"
^+=::SendInput "^tp{Enter}"
; For JP keyboards
;^-::SendInput "^tb{Enter}"
;^+-::SendInput "^tp{Enter}"

; Fonts
^!+s::SendInput "^tfsymbol{Enter}"
^!+a::SendInput "^tfarial{Enter}"
^!+h::SendInput "^tfhelvetica{Enter}"
; }}} Power Point

; Word {{{
#HotIf WinActive("ahk_class OpusApp")
^=::SendInput "^tb{Enter}"
^+=::SendInput "^tp{Enter}"
; for JP keyboards
;^-::SendInput "^tb{Enter}"
;^+-::SendInput "^tp{Enter}"
; }}} Word

; Explorer {{{
#HotIf WinActive("ahk_class CabinetWClass")
; }}} Explorer

; CLCL {{{
#HotIf
#c::SendInput "!c"
#HotIf WinActive("ahk_exe CLCL.exe") ; does not work...
j::
{
  SendInput "{Down}"
}
k::SendInput "{Up}"
; }}} CLCL

; Everthing {{{
#HotIf WinActive("ahk_class EVERYTHING")
Enter::
{
  SendInput "{Enter}"
  Sleep(200)
  if WinActive("ahk_class EVERYTHING") {
    SendInput "{Enter}"
    Sleep(500)
  }
  WinActivate("ahk_class EVERYTHING")
  Sleep(200)
  SendInput "{Esc}"
}
; }}} Everything

; Firefox/Chrome/Edge {{{
#HotIf WinActive("ahk_group Browser")
^WheelDown::SendInput "{WheelDown}"
^WheelUp::SendInput "{WheelUp}"
; }}} Firefox/Chrome/Edge

; Obsidian {{{
#HotIf WinActive("ahk_exe Obsidian.exe")
; Search
^!e::
{
  SendInput "^+f"
}

; Open inspector
!+i::SendInput "^+i"

#HotIf not WinExist("ahk_exe Obsidian.exe")
; Search
^!e::
{
  LaunchApp("ahk_exe Obsidian.exe", obsidian_app)
  Sleep(10000)
  SendInput "^+f"
}

; Open Daily Note
^!d::
{
  LaunchApp("ahk_exe Obsidian.exe", obsidian_app)
  Sleep(10000)
  SendInput "^!d"
}

#HotIf not WinActive("ahk_exe Obsidian.exe")
; Search
^!e::
{
  WinActivate("ahk_exe Obsidian.exe")
  SendInput "^+f"
}

; Open Daily Note
^!d::
{
  WinActivate("ahk_exe Obsidian.exe")
  SendInput "^+q"
  SendInput "^!d"
}

; }}} Obsidian

; Global Settings {{{
#HotIf
; Basic Settings {{{

; Suspend
;Esc & Tab::
;{
;  Suspend, Toggle
;}
; For Alt-Ctrl Swap (swapped by KeySwap)
; To assign ^Tab, need to add < or > to choose left or right
<^Tab::AltTab
;<+<^Tab::ShiftAltTab ; can not assigned...
;LCtrl & Tab::
;{
;  if GetKeyState("Shift","P"){
;    SendInput "{ShiftAltTab}"
;  }else{
;    SendInput "{AltTab}"
;  }
;}
;Alt & Tab::
;{
;  if GetKeyState("Shift","P"){
;    SendInput "^+{taB}"
;  }else{
;    SendInput "^{Tab}"
;  }
;}
!Tab::SendInput "^{Tab}"
!+Tab::SendInput "^+{Tab}"

;!m::SendInput "^m"
;^m::SendInput "!m"
;>^m::SendInput "!m"
;Ctrl & Left::SendInput "!{Left}"
;Ctrl & Right::SendInput "!{Right}"

; Cortana
!^f::SendInput "#s"

; Other basic settings
!Space::SendInput "{vkF3sc029}" ; IME by A-Space
^Space::SendInput "{vkF3sc029}" ; IME by C-Space
;{vkF3sc029}               ; 変換
;{vk1Dsc07B}               ; 無変換
!^a::SendInput "!{Space}n"      ; Minimize window
!4::SendInput "!{F4}"           ; Close window
^4::SendInput "!{F4}"           ; Close window
!d::SendInput "{Del}"           ; Always Delete with A-d: Does not work on Windows 11?
!o::SendInput "!{Left}"         ; Go to previous page
!i::SendInput "!{Right}"        ; Go to next page ; Use Alt-i instead of Ctrl-i to avoid to disable Ctrl-i for katakana
^Space::!`                      ; IME
^h::SendInput "{BS}"            ; Always BS with C-h
;^h::
;{
;  While GetKeyState("h","p"){
;    SendInput "{BS}"
;    TrayTip,Start:,%n%,10,,
;    Sleep(50)
;  }
;}

;^j::SendInput "{Enter}"      ; C-j to Enter

; For HHKB
; ESC to ` like normal keyboard (ESC is placed on the left of 1 in HHKB)
Esc::
{
  If (KeyWait("Esc", "T0.3")){
    SendInput "{Esc}"
    KeyWait "Esc"
  }else{
    SendInput "``"
    KeyWait "Esc"
  }
}

;; Disable alt to menu
;Alt::KeyWait "Alt"
;LAlt Up::SendInput "{Enter}"
; }}} Basic Settings

; Cursor, Mouse, Window move/size {{{
; Cursor {{{
!^h::SendInput "{Left}"
!^j::SendInput "{Down}"
!^k::SendInput "{Up}"
!^l::SendInput "{Right}"
; }}} Cursor

; Mouse {{{
; Mouse Move
^+h::MouseMove -1 * MouseMoveSize, 0, 0, "R"
^+j::MouseMove 0, MouseMoveSize, 0, "R"
^+k::MouseMove 0, -1 * MouseMoveSize, 0, "R"
^+l::MouseMove MouseMoveSize, 0, 0, "R"

; Click
^+n::MouseClick "Left"
^+p::MouseClick "Right"
; Right click on current window

; Mouse wheel
!^m::MouseClick "WheelDown", , , MouseWheelSize
!^,::MouseClick "WheelUp", , , MouseWheelSize
; }}} Mouse

; Window move {{{

; Move a little
^+y::
{
  WinGetPos &X, &Y, , , "A" ; A for Active Window
  WinMove X - WinMoveSize, Y, , , "A"
}

^+u::
{
  WinGetPos &X, &Y, , , "A"
  WinMove X, Y + WinMoveSize, , , "A"
}

^+i::
{
  WinGetPos &X, &Y, , , "A"
  WinMove X, Y - WinMoveSize, , , "A"
}

^+o::
{
  WinGetPos &X, &Y, , , "A"
  WinMove X + WinMoveSize, Y, , , "A"
}

; Move to a different screen
!^+y:: SendInput "#+{Left}"
!^+u:: SendInput "#+{Down}"
!^+i:: SendInput "#+{Up}"
!^+o:: SendInput "#+{Right}"

; }}} Window move

; Virtual desktop {{{
^!y::SendInput "#^{Left}"
^!o::SendInput "#^{Right}"
; }}} Virtual desktop


; Window size {{{

; Almost full
^!Enter::
!+Enter::
{
  ;WinGetPos &X, &Y, &W, &H, Program Manager ; Full Desktop
  ;Msgbox "Pos At " X ", " Y ", " W ", " H
  MonitorGetWorkArea(, &MWALeft, &MWATop, &MWARight, &MWABottom) ; w/o Taskbar
  ;Msgbox MWALeft ", " MWATop ", " MWARight ", " MWABottom
  WinMove MWALeft + LMargin, MWATop + TMargin
    , MWARight - MWALeft - LMargin - RMargin
    , MWABottom - MWATop - TMargin - BMargin
    , "A"
}

; Minsize
^!+Enter::
{
  MonitorGetWorkArea(, &MWALeft, &MWATop, &MWARight, &MWABottom) ; w/o Taskbar
  WinMove MWALeft + LMargin, MWATop + TMargin
    , (MWARight - MWALeft - LMargin - RMargin) * Minsize
    , (MWABottom - MWATop - TMargin - BMargin) * Minsize
    , "A"
}

; Half size
!+h::
{
  MonitorGetWorkArea(, &MWALeft, &MWATop, &MWARight, &MWABottom) ; w/o Taskbar
  WinMove MWALeft + LMargin
    , MWATop + TMargin
    , (MWARight - MWALeft - LMargin - RMargin) * 0.5
    , MWABottom - MWATop - TMargin - BMargin
    , "A"
}

!+j::
{
  MonitorGetWorkArea(, &MWALeft, &MWATop, &MWARight, &MWABottom) ; w/o Taskbar
  WinMove MWALeft + LMargin
    , MWATop + (MWABottom - MWATop) * 0.5
    , MWARight - MWALeft - LMargin - RMargin
    , (MWABottom - MWATop - TMargin - BMargin) * 0.5
    , "A"
}

!+k::
{
  MonitorGetWorkArea(, &MWALeft, &MWATop, &MWARight, &MWABottom) ; w/o Taskbar
  WinMove MWALeft + LMargin
    , MWATop + TMargin
    , MWARight - MWALeft - LMargin - RMargin
    , (MWABottom - MWATop - TMargin - BMargin) * 0.5
    , "A"
}

!+l::
{
  MonitorGetWorkArea(, &MWALeft, &MWATop, &MWARight, &MWABottom) ; w/o Taskbar
  WinMove MWALeft + (MWARight - MWALeft) * 0.5
    , MWATop + TMargin
    , (MWARight - MWALeft - LMargin - RMargin) * 0.5
    , MWABottom - MWATop - TMargin - BMargin
    , "A"
}

; Half Half size
^!+h::
{
  MonitorGetWorkArea(, &MWALeft, &MWATop, &MWARight, &MWABottom) ; w/o Taskbar
  WinMove MWALeft + LMargin
    , MWATop + TMargin
    , (MWARight - MWALeft - LMargin - RMargin) * 0.5
    , (MWABottom - MWATop - TMargin - BMargin) * 0.5
    , "A"
}

^!+j::
{
  MonitorGetWorkArea(, &MWALeft, &MWATop, &MWARight, &MWABottom) ; w/o Taskbar
  WinMove MWALeft + LMargin
    , MWATop + (MWABottom - MWATop) * 0.5
    , (MWARight - MWALeft - LMargin - RMargin) * 0.5
    , (MWABottom - MWATop - TMargin - BMargin) * 0.5
    , "A"
}

^!+k::
{
  MonitorGetWorkArea(, &MWALeft, &MWATop, &MWARight, &MWABottom) ; w/o Taskbar
  WinMove MWALeft + (MWARight - MWALeft) * 0.5
    , MWATop + TMargin
    , (MWARight - MWALeft - LMargin - RMargin) * 0.5
    , (MWABottom - MWATop - TMargin - BMargin) * 0.5
    , "A"
}

^!+l::
{
  MonitorGetWorkArea(, &MWALeft, &MWATop, &MWARight, &MWABottom) ; w/o Taskbar
  WinMove MWALeft + (MWARight - MWALeft) * 0.5
    , MWATop + (MWABottom - MWATop) * 0.5
    , (MWARight - MWALeft - LMargin - RMargin) * 0.5
    , (MWABottom - MWATop - TMargin - BMargin) * 0.5
    , "A"
}

; Resize
!+y::
{
  WinGetPos &X, &Y, &W, &H, "A"
  WinMove X, Y, W - WinResizeSize, H, "A"
}

!+u::
{
  WinGetPos &X, &Y, &W, &H, "A"
  WinMove X, Y, W, H + WinResizeSize, "A"
}

!+i::
{
  WinGetPos &X, &Y, &W, &H, "A"
  WinMove X, Y, W, H - WinResizeSize, "A"
}

!+o::
{
  WinGetPos &X, &Y, &W, &H, "A"
  WinMove X, Y, W + WinResizeSize, H, "A"
}

; }}} Window size
; }}} Cursor, Mouse, Window move
; }}} Global Settings
