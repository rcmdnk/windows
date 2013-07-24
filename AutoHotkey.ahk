﻿; Tips {{{
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
TMargin=5
BMargin=5
LMargin=5
RMargin=155 ; sidebar = 150px
MinSize=0.7

; For Terminal/Vim
GroupAdd Terminal, ahk_class PuTTY
GroupAdd Terminal, ahk_class mintty ; cygwin
GroupAdd Terminal, ahk_class Vim

#Include  %A_ScriptDir%\vim.ahk

Return
; }}}

; Basic Settings, HotKeys, Functions {{{
; Settings

#UseHook On ; Make it a bit slow, but can avoid infinitude loop
            ; Same as "$" for each hotkey
#InstallKeybdHook ; For checking key history
                  ; Use ~500kB memory?

#HotkeyInterval 2000 ; Hotkey inteval (default 2000 milliseconds).
#MaxHotkeysPerInterval 70 ; Max hotkeys perinterval (default 50).


; For HHK
;vkFFsc079::RAlt
;vkFFsc07b::LAlt
vkFFsc079::RCtrl
vkFFsc07b::LCtrl

;; Ref for IME: http://www6.atwiki.jp/eamat/pages/17.html
;; Get IME Status. 0: Off, 1: On
;IME_GET(WinTitle="A")  {
;  ControlGet,hwnd,HWND,,,%WinTitle%
;  if (WinActive(WinTitle)) {
;    ptrSize := !A_PtrSize ? 4 : A_PtrSize
;    VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
;    NumPut(cbSize, stGTI,  0, "UInt")   ;   DWORD   cbSize;
;    hwnd := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
;        ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd
;  }
;
;  Return DllCall("SendMessage"
;      , UInt, DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hwnd)
;      , UInt, 0x0283  ;Message : WM_IME_CONTROL
;      ,  Int, 0x0005  ;wParam  : IMC_GETOPENSTATUS
;      ,  Int, 0)      ;lParam  : 0
;}
;; Get input status. 1: Converting, 2: Have converting window, 0: Others
;IME_GetConverting(WinTitle="A",ConvCls="",CandCls="") {
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
;  ControlGet,hwnd,HWND,,,%WinTitle%
;  if (WinActive(WinTitle)) {
;    ptrSize := !A_PtrSize ? 4 : A_PtrSize
;    VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
;    NumPut(cbSize, stGTI,  0, "UInt")   ;   DWORD   cbSize;
;    hwnd := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
;      ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd
;  }
;
;  WinGet, pid, PID,% "ahk_id " hwnd
;  tmm:=A_TitleMatchMode
;  SetTitleMatchMode, RegEx
;  ret := WinExist("ahk_class " . CandCls . " ahk_pid " pid) ? 2
;      :  WinExist("ahk_class " . CandGCls                 ) ? 2
;      :  WinExist("ahk_class " . ConvCls . " ahk_pid " pid) ? 1
;      :  0
;  SetTitleMatchMode, %tmm%
;  Return ret
;}
;; Set IME, SetSts=0: Off, 1: On, return 0 for success, others for non-success
;IME_SET(SetSts=0, WinTitle="A")    {
;  ControlGet,hwnd,HWND,,,%WinTitle%
;  if(WinActive(WinTitle)){
;    ptrSize := !A_PtrSize ? 4 : A_PtrSize
;    VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
;    NumPut(cbSize, stGTI,  0, "UInt")   ;   DWORD   cbSize;
;    hwnd := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
;        ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd
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
; On Terminal/Vim
#IfWInActive, ahk_group Terminal
Esc:: ; Just send Esc at converting.
  if (IME_GET(A)) {
    if (IME_GetConverting(A)) {
      Send,{Esc}
    } else {
      IME_SET()
    }
  } else {
    Send,{Esc}
  }
  Return
^[:: ; Go to Normal mode (for vim) with IME off even at converting.
  if (IME_GET(A)) {
    Send,{Esc}
    Sleep 1 ; wait 1 ms (Need to stop converting)
    IME_SET()
    Send,{Esc}
  } else {
    Send,{Esc}
  }
  Return
#IfWInActive

; Other than Terminal/Vim
#IfWInNotActive, ahk_group Terminal
^[::Send,{Esc}             ; Always C-[ to ESC, like vim
#IfWInNotActive
; }}} Terminal/Vim

; Power Point {{{
#IfWInActive, ahk_class PP12FrameClass
; Select one character
^Space::Send,{Right}+{Left}

; Subscript/Superscript
^=::Send,^tb{Enter}
^+=::Send,^tp{Enter}
; For JP keyboards
;^-::Send,^tb{Enter}
;^+-::Send,^tp{Enter}

; Fonts
^+s::Send,^tfsymbol{Enter}
^+a::Send,^tfarial{Enter}
^+h::Send,^tfhelvetica{Enter}
#IfWInActive
; }}} Power Point

; Word {{{
#IfWInActive, ahk_class OpusApp
^Space::Send,{Right}+{Left}
^=::Send,^tb{Enter}
^+=::Send,^tp{Enter}
; for JP keyboards
;^-::Send,^tb{Enter}
;^+-::Send,^tp{Enter}
#IfWInActive
; }}} Word

; Explorer {{{
#IfWInActive, ahk_class CabinetWClas
; Next/Previous page
^i::Send,!{Right}
^o::Send,!{Left}
#IfWInActive
; }}} Explorer

; CLCL {{{
;#IfWInActive, ahk_class CLCLMain
#IfWInActive, CLCL ; both window/title do not working...
j::
  Msgbox, clcl_down
  Send,{Down}
  Return
K::Send,{Up}
#IfWInActive
; }}} Explorer

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
  if GetKeyState("Shift","P") {
    Send,^+{Tab} ; dosen't work ()
  }else{
    Send,^{Tab}
  }
  Return

;!m::Send,^m
;^m::Send,!m
^m::Send,!m
Ctrl & Left::Send,!{Left}
Ctrl & Right::Send,!{Right}

; Other basic settings
!Space::Send,{vkF3sc029}   ; IME by A-Space
^Space::Send,{vkF3sc029}   ; IME by C-Space
; {vkF3sc029}              ; 変換
; {vk1Dsc07B}              ; 無変換
^h::Send,{BS}              ; Always BS with C-h
!a::Send,^{Space}n        ; Minimize window
!4::Send,!{F4}             ; Close window
^4::Send,!{F4}             ; Close window
!d::Send,{Del}             ; Always Delete with A-d
;^o::Send,!{Left}           ; Go to previous page
;^i::Send,!{Right}          ; Go to nexe page
^Space::!`                 ; IME

; For HHK
; ESC to ` like normal keyboard (ESC is placed on the left of 1 in HHK)
!1::!`                ; IME
; }}} Basic Settings

; Cursor, Mouse, Window move/size {{{
; Cursor {{{
!^h::Send,{Left}
!^j::Send,{Down}
!^k::Send,{Up}
!^l::Send,{Right}
; }}} Cursor

; Mouse {{{
; Mouse Move
!^y::MouseMove, -10, 0, 0, R
!^u::MouseMove, 0, 10, 0, R
!^i::MouseMove, 0, -10, 0, R
!^o::MouseMove, 10, 0, 0, R

; Click
!^n::MouseClick, Left
!^p::MouseClick, Right
; Right click on current window
!v::
  MouseMove, 50, 50, 0
  MouseClick, Right
  Return

; Mouse wheel
!^m::MouseClick, WheelDown,,,  2
!^,::MouseClick, WheelUp,,,  2
; }}} Mouse

; Window move {{{
^+y::
  WinGetPos, X, Y, , , A ;A for Active Window
  ;Msgbox, Pos At %X% %Y%
  WinMove, A, ,X-20, Y,
  ;Msgbox, Moved At %X%-20 %Y%
  Return ; Necessary for mapping which has at least 2 commands
^+u::
  WinGetPos, X, Y, , , A
  WinMove, A, ,X, Y+20
  Return
^+i::
  WinGetPos, X, Y, , , A
  WinMove, A, ,X, Y-20
  Return
^+o::
  WinGetPos, X, Y, , , A
  WinMove, A, ,X+20, Y
  Return
; }}} Window move

; Window size {{{
^!Enter::
  ;WinGetPos, X, Y, W, H, Program Manager ; Full Desktop
  ;Msgbox, Pos At %X% %Y% %W% %H%
  SysGet, MWA, MonitorWorkArea ; w/o Taskbar
  ;Msgbox, %MWALeft% %MWATop% %MWARight% %MWABottom%
  WinMove, A, ,MWALeft+LMargin, MWATop+TMargin
    , MWARight-MWALeft-LMargin-RMargin
    , MWABottom-MWATop-TMargin-BMargin
  Return
^!+Enter::
  ;WinGetPos, X, Y, W, H, Program Manager ; Full Desktop
  ;Msgbox, Pos At %X% %Y% %W% %H%
  SysGet, MWA, MonitorWorkArea ; w/o Taskbar
  ;Msgbox, %MWALeft% %MWATop% %MWARight% %MWABottom%
  WinMove, A, ,MWALeft+LMargin, MWATop+TMargin
    , (MWARight-MWALeft-LMargin-RMargin)*MinSize
    , (MWABottom-MWATop-TMargin-BMargin)*MinSize
  Return
; }}} Window size
; }}} Cursor, Mouse, Window move
; }}} Global Settings
