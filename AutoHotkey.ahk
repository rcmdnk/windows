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

; For Terminal/Vim
GroupAdd Terminal, ahk_class PuTTY
GroupAdd Terminal, ahk_class mintty ; cygwin
GroupAdd Terminal, ahk_class TMobaXtermForm
GroupAdd Terminal, ahk_class TFormDetachedTab
GroupAdd Terminal, ahk_class ConsoleWindowClass
GroupAdd Terminal, ahk_exe powershell.exe
GroupAdd Terminal, ahk_exe vim.exe
GroupAdd TerminalVim, ahk_group Terminal
GroupAdd TerminalVim, ahk_class Vim

; For browsers
GroupAdd, Browser, ahk_exe chrome.exe
GroupAdd, Browser, ahk_exe firefox.exe
GroupAdd, Browser, ahk_exe ApplicationFrameHost.exe ; Edge

; Mouse Gestures
GroupAdd, MouseGesture, ahk_group Broser
GroupAdd, MouseGesture, ahk_exe explorer.exe

; External files
VimIcon := 1
#Include %A_LineFile%\..\submodules\vim_ahk\vim.ahk
#Include %A_LineFile%\..\AutoCorrect.ahk

Return
; }}}

;; Basic Settings, HotKeys, Functions {{{
; Settings

#UseHook On ; Make it a bit slow, but can avoid infinitude loop
            ; Same as "$" for each hotkey
#InstallKeybdHook ; For checking key history
                  ; Use ~500kB memory?

#HotkeyInterval 1000 ; Hotkey inteval (default 2000 milliseconds).
#MaxHotkeysPerInterval 100 ; Max hotkeys perinterval (default 50).

; For HHKB
vkFFsc079::RCtrl
vkFFsc07b::LCtrl
; }}}

; Terminal/Vim {{{
; ESC + IME
#IfWInActive, ahk_group TerminalVim
Esc:: ; Just send Esc at converting.
  if(VIM_IME_GET(A)){
    if(VIM_IME_GetConverting(A)){
      Send, {Esc}
    }else{
      VIM_IME_SET()
    }
  }else{
    Send, {Esc}
  }
Return

^[:: ; Go to Normal mode (for vim) with IME off even at converting.
  if(VIM_IME_GetConverting(A)){
    Send, {Esc}
    Sleep 1 ; wait 1 ms (Need to stop converting)
  }
  if(VIM_IME_GET(A)){
    VIM_IME_SET()
    Send, {Esc}
  }else{
    Send, {Esc}
  }
Return

^m::Send, ^m ; Use Ctrl-m as is

; Paste
#IfWInActive, ahk_group Terminal
!v::
  ;StringSplit, strout, clipboard, `n
  ;If(strout0>1 or InStr(clipboard, "sudo")>0){
  ;  MsgBox, 308, Clipboard, %clipboard%`n`n Do you want to paste?
  ;  IfMsgBox, No
  ;  {
  ;    Return
  ;  }
  ;}
  ;SendInput %clipboard%
  ;Return
  Sleep,200
  MouseClick, Right, 50, 50, 1
Return

#IfWInActive, ahk_class Vim
!v::Send, {Alt}ep

; Command Promp, PowerShell, Bash on Ubuntu on Windows {{{
#IfWinActive ahk_class ConsoleWindowClass
^v::Send, ^q
!v::
  SendInput %clipboard%
Return
; }}} Command Prompt

; Other than Terminal/Vim
#IfWInNotActive, ahk_group TerminalVim
^[::Send, {Esc}             ; Always C-[ to ESC, like vim
^d::Send, {Del}             ; Always Delete with C-d
; }}} Terminal/Vim

; Power Point {{{
#IfWInActive, ahk_class PP12FrameClass
; Subscript/Superscript
^=::Send, ^tb{Enter}
^+=::Send, ^tp{Enter}
; For JP keyboards
;^-::Send, ^tb{Enter}
;^+-::Send, ^tp{Enter}

; Fonts
^!+s::Send, ^tfsymbol{Enter}
^!+a::Send, ^tfarial{Enter}
^!+h::Send, ^tfhelvetica{Enter}
; }}} Power Point

; Word {{{
#IfWInActive, ahk_class OpusApp
^=::Send, ^tb{Enter}
^+=::Send, ^tp{Enter}
; for JP keyboards
;^-::Send, ^tb{Enter}
;^+-::Send, ^tp{Enter}
; }}} Word

; Explorer {{{
#IfWInActive, ahk_class CabinetWClass
; Next/Previous page
^i::Send, !{Right}
^o::Send, !{Left}
; }}} Explorer

; CLCL {{{
;#IfWInActive, ahk_class CLCLMain
#IfWInActive, CLCL ; both window/title do not working...
j::
  Msgbox, clcl_down
  Send, {Down}
Return

K::Send, {Up}
; }}} Explorer

; Everthing {{{
#IfWinActive, ahk_class EVERYTHING
Return::
  Send, {Enter}
  Sleep, 200
  IfWinActive, ahk_class EVERYTHING
  {
    Send,{Enter}
    Sleep, 500
  }
  WinActivate, ahk_class EVERYTHING
  Sleep, 200
  Send, {Esc}
Return
; }}} Everything

; Firefox/Chrome/Edge {{{
#IfWinActive, ahk_group Browser
;^WheelDown::Send, {WheelDown}
;^WheelUp::Send, {WheelUp}
^WheelDown::Return
^WheelUp::Return
; }}} Firefox/Chrome

; Mouse Gestures {{{
#IfWinActive, ahk_group MouseGesture
;LButton & RButton::Send, ^{Tab}
;RButton & LButton::Send, ^+{Tab}

; }}} Firefox/Chrome

; Global Settings {{{
#if
; Basic Settings {{{

; Suspend
;Esc & Tab::
;  Suspend, Toggle
;  Return
; For Alt-Ctrl Swap (swapped by KeySwap)
; To assign ^Tab, need to add < or > to choose left or right
<^Tab::AltTab
;<+<^Tab::ShiftAltTab ; can not assigned...
;LCtrl & Tab::
;  if GetKeyState("Shift","P"){
;    Send, {ShiftAltTab}
;  }else{
;    Send, {AltTab}
;  }
;Return
;Alt & Tab::
;  if GetKeyState("Shift","P"){
;    Send, ^+{taB}
;  }else{
;    Send, ^{Tab}
;  }
;Return
!Tab::Send, ^{Tab}
!+Tab::Send, ^+{Tab}

;!m::Send, ^m
;^m::Send, !m
;>^m::Send, !m
;Ctrl & Left::Send, !{Left}
;Ctrl & Right::Send, !{Right}

; Virtual desktop
^!+h::Send, #^{Left}
^!+l::Send, #^{Right}

; Cortana
!^f::Send, #s

; CLCL
#c::Send, !c

; Other basic settings
!Space::Send, {vkF3sc029} ; IME by A-Space
^Space::Send, {vkF3sc029} ; IME by C-Space
;{vkF3sc029}               ; 変換
;{vk1Dsc07B}               ; 無変換
!^a::Send, !{Space}n       ; Minimize window
!4::Send, !{F4}           ; Close window
^4::Send, !{F4}           ; Close window
!d::Send, {Del}           ; Always Delete with A-d
;^o::Send,!{Left}          ; Go to previous page
;^i::Send,!{Right}         ; Go to nexe page
^Space::!`                ; IME

^h::Send, {BS}            ; Always BS with C-h
;^h::
;  While GetKeyState("h","p"){
;    Send {BS}
;    TrayTip,Start:,%n%,10,,
;    Sleep 50
;  }
;  return

;^j::Send,{Enter}      ; C-j to Enter

; For HHKB
; ESC to ` like normal keyboard (ESC is placed on the left of 1 in HHKB)
!1::!`                ; IME
; }}} Basic Settings

; Cursor, Mouse, Window move/size {{{
; Cursor {{{
!^h::Send, {Left}
!^j::Send, {Down}
!^k::Send, {Up}
!^l::Send, {Right}
; }}} Cursor

; Mouse {{{
; Mouse Move
^+h::MouseMove, -10, 0, 0, R
^+j::MouseMove, 0, 10, 0, R
^+k::MouseMove, 0, -10, 0, R
^+l::MouseMove, 10, 0, 0, R

; Click
^+n::MouseClick, Left
^+p::MouseClick, Right
; Right click on current window

; Mouse wheel
!^m::MouseClick, WheelDown, , , 2
!^,::MouseClick, WheelUp, , , 2
; }}} Mouse

; Window move {{{

; Move a little
^+y::
  WinGetPos, X, Y, , , A ;A for Active Window
  WinMove, A, ,X-20, Y,
Return

^+u::
  WinGetPos, X, Y, , , A
  WinMove, A, , X, Y+20
Return

^+i::
  WinGetPos, X, Y, , , A
  WinMove, A, , X, Y-20
Return

^+o::
  WinGetPos, X, Y, , , A
  WinMove, A, , X+20, Y
Return

; Move to a different screen
!^+y:: Send, #+{Left}
!^+u:: Send, #+{Down}
!^+i:: Send, #+{Up}
!^+o:: Send, #+{Right}

; }}} Window move

; Window size {{{

; Almost full
^!Enter::
!+Enter::
  ;WinGetPos, X, Y, W, H, Program Manager ; Full Desktop
  ;Msgbox, Pos At %X% %Y% %W% %H%
  SysGet, MWA, MonitorWorkArea ; w/o Taskbar
  ;Msgbox, %MWALeft% %MWATop% %MWARight% %MWABottom%
  WinMove, A, , MWALeft+LMargin, MWATop+TMargin
    , MWARight-MWALeft-LMargin-RMargin
    , MWABottom-MWATop-TMargin-BMargin
Return

; Minsize
^!+Enter::
  SysGet, MWA, MonitorWorkArea ; w/o Taskbar
  WinMove, A, , MWALeft+LMargin, MWATop+TMargin
    , (MWARight-MWALeft-LMargin-RMargin)*Minsize
    , (MWABottom-MWATop-TMargin-BMargin)*Minsize
Return

; Half size
!+h::
  SysGet, MWA, MonitorWorkArea ; w/o Taskbar
  WinMove, A, , MWALeft+LMargin, MWATop+TMargin
    , (MWARight-MWALeft-LMargin-RMargin)*0.5
    , MWABottom-MWATop-TMargin-BMargin
Return

!+j::
  SysGet, MWA, MonitorWorkArea ; w/o Taskbar
  WinMove, A, , MWALeft+LMargin
    , MWATop+(MWABottom-MWATop)*0.5
    , MWARight-MWALeft-LMargin-RMargin
    , (MWABottom-MWATop-TMargin-BMargin)*0.5
Return

!+k::
  SysGet, MWA, MonitorWorkArea ; w/o Taskbar
  WinMove, A, , MWALeft+LMargin, MWATop+TMargin
    , MWARight-MWALeft-LMargin-RMargin
    , (MWABottom-MWATop-TMargin-BMargin)*0.5
Return

!+l::
  SysGet, MWA, MonitorWorkArea ; w/o Taskbar
  WinMove, A, , MWALeft+(MWARight-MWALeft)*0.5
    , MWATop+TMargin
    , (MWARight-MWALeft-LMargin-RMargin)*0.5
    , MWABottom-MWATop-TMargin-BMargin
Return

; Resize
!+y::
  WinGetPos, X, Y, W, H, A
  WinMove, A, ,X, Y, W-20, H
Return

!+u::
  WinGetPos, X, Y, W, H, A
  WinMove, A, ,X, Y, W, H+20
Return

!+i::
  WinGetPos, X, Y, W, H, A
  WinMove, A, ,X, Y, W, H-20
Return

!+o::
  WinGetPos, X, Y, W, H, A
  WinMove, A, ,X, Y, W+20, H
Return

; }}} Window size
; }}} Cursor, Mouse, Window move
; }}} Global Settings
