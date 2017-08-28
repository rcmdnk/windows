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

; Auto-execute section {{{
; Auto execute section is the region before any return/hotkey

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

; Vim mode
VimIcon := 1
#Include %A_LineFile%\..\submodules\vim_ahk\vim.ahk

; Auto correct
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
;vkFFsc079::RAlt
;vkFFsc07b::LAlt
vkFFsc079::RCtrl
vkFFsc07b::LCtrl

;; Ref for IME: http://www6.atwiki.jp/eamat/pages/17.html
;; Get IME Status. 0: Off, 1: On
;VIM_IME_GET(WinTitle="A"){
;  ControlGet, hwnd,HWND , , , %WinTitle%
;  if(WinActive(WinTitle)){
;    ptrSize := !A_PtrSize ? 4 : A_PtrSize
;    VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
;    NumPut(cbSize, stGTI, 0, "UInt") ; DWORD cbSize;
;    hwnd := DllCall("GetGUIThreadInfo", Uint, 0, Uint, &stGTI)
;        ? NumGet(stGTI, 8+PtrSize, "UInt") : hwnd
;  }
;
;  Return DllCall("SendMessage"
;      , UInt, DllCall("imm32\ImmGetDefaultIMEWnd", Uint, hwnd)
;      , UInt, 0x0283  ;Message : WM_IME_CONTROL
;      ,  Int, 0x0005  ;wParam  : IMC_GETOPENSTATUS
;      ,  Int, 0)      ;lParam  : 0
;}
;
;; Get input status. 1: Converting, 2: Have converting window, 0: Others
;VIM_IME_GetConverting(WinTitle="A", ConvCls="", CandCls=""){
;  ; Input windows, candidate windows (Add new IME with "|")
;  ConvCls .= (ConvCls ? "|" : "")                 ;--- Input Window ---
;    .  "ATOK\d+CompStr"                           ; ATOK
;    .  "|imejpstcnv\d+"                           ; MS-IME
;    .  "|WXGIMEConv"                              ; WXG
;    .  "|SKKIME\d+\.*\d+UCompStr"                 ; SKKIME Unicode
;    .  "|MSCTFIME Composition"                    ; Google IME
;  CandCls .= (CandCls ? "|" : "")                 ;--- Candidate Window ---
;    .  "ATOK\d+Cand"                              ; ATOK
;    .  "|imejpstCandList\d+|imejpstcand\d+"       ; MS-IME 2002(8.1)XP
;    .  "|mscandui\d+\.candidate"                  ; MS Office IME-2007
;    .  "|WXGIMECand"                              ; WXG
;    .  "|SKKIME\d+\.*\d+UCand"                    ; SKKIME Unicode
; CandGCls := "GoogleJapaneseInputCandidateWindow" ; Google IME
;
;  ControlGet, hwnd, HWND, , , %WinTitle%
;  if(WinActive(WinTitle)){
;    ptrSize := !A_PtrSize ? 4 : A_PtrSize
;    VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
;    NumPut(cbSize, stGTI, 0, "UInt")   ;   DWORD   cbSize;
;    hwnd := DllCall("GetGUIThreadInfo", Uint, 0, Uint, &stGTI)
;      ? NumGet(stGTI, 8+PtrSize, "UInt") : hwnd
;  }
;
;  WinGet, pid, PID, % "ahk_id " hwnd
;  tmm := A_TitleMatchMode
;  SetTitleMatchMode, RegEx
;  ret := WinExist("ahk_class " . CandCls . " ahk_pid " pid) ? 2
;      :  WinExist("ahk_class " . CandGCls                 ) ? 2
;      :  WinExist("ahk_class " . ConvCls . " ahk_pid " pid) ? 1
;      :  0
;  SetTitleMatchMode, %tmm%
;  Return ret
;}
;
;; Set IME, SetSts=0: Off, 1: On, return 0 for success, others for non-success
;VIM_IME_SET(SetSts=0, WinTitle="A"){
;  ControlGet, hwnd, HWND, , , %WinTitle%
;  if(WinActive(WinTitle)){
;    ptrSize := !A_PtrSize ? 4 : A_PtrSize
;    VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
;    NumPut(cbSize, stGTI, 0, "UInt") ; DWORD  cbSize;
;    hwnd := DllCall("GetGUIThreadInfo", Uint, 0, Uint, &stGTI)
;        ? NumGet(stGTI, 8+PtrSize, "UInt") : hwnd
;  }
;
;  Return DllCall("SendMessage"
;    , UInt, DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hwnd)
;    , UInt, 0x0283  ;Message : WM_IME_CONTROL
;    ,  Int, 0x006   ;wParam  : IMC_SETOPENSTATUS
;    ,  Int, SetSts) ;lParam  : 0 or 1
;}

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
#IfWInActive

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

#IfWInActive
#IfWInActive, ahk_class Vim
!v::Send, {Alt}ep
#IfWInActive

; Command Promp, PowerShell, Bash on Ubuntu on Windows {{{
#IfWinActive ahk_class ConsoleWindowClass
^v::Send, ^q
!v::
  SendInput %clipboard%
Return
#IfWInActive
; }}} Command Prompt

; Other than Terminal/Vim
#IfWInNotActive, ahk_group TerminalVim
^[::Send, {Esc}             ; Always C-[ to ESC, like vim
^d::Send, {Del}             ; Always Delete with C-d
#IfWInNotActive
; }}} Terminal/Vim

; Power Point {{{
#IfWInActive, ahk_class PP12FrameClass
; Select one character
^Space::Send, {Right}+{Left}

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
#IfWInActive
; }}} Power Point

; Word {{{
#IfWInActive, ahk_class OpusApp
^Space::Send, {Right}+{Left}
^=::Send, ^tb{Enter}
^+=::Send, ^tp{Enter}
; for JP keyboards
;^-::Send, ^tb{Enter}
;^+-::Send, ^tp{Enter}
#IfWInActive
; }}} Word

; Explorer {{{
#IfWInActive, ahk_class CabinetWClass
; Next/Previous page
^i::Send, !{Right}
^o::Send, !{Left}
#IfWInActive
; }}} Explorer

; CLCL {{{
;#IfWInActive, ahk_class CLCLMain
#IfWInActive, CLCL ; both window/title do not working...
j::
  Msgbox, clcl_down
  Send, {Down}
Return

K::Send, {Up}
#IfWInActive
; }}} Explorer

; Everthing {{{
#IfWInActive, ahk_class EVERYTHING
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

#IfWInActive
; }}} Everything

; Fiefox {{{
;#IfWinActive ahk_exe firefox.exe
;^j::Send, ^j
;#IfWInActive
; }}} Firefox

; Global Settings {{{
#if
; Basic Settings {{{

; Suspend
;Esc & Tab::
;  Suspend, Toggle
;  Return
; For Alt-Ctrl Swap (swapped by KeySwap)
LCtrl & Tab::AltTab
Alt & Tab::
  if GetKeyState("Shift","P"){
    Send, ^+{taB} ; dosen't work ()
  }else{
    Send, ^{Tab}
  }
Return

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

^!+Enter::
  SysGet, MWA, MonitorWorkArea ; w/o Taskbar
  WinMove, A, , MWALeft+LMargin, MWATop+TMargin
    , (MWARight-MWALeft-LMargin-RMargin)*Minsize
    , (MWABottom-MWATop-TMargin-BMargin)*Minsize
Return

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
