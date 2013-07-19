; Tips {{{
; #: win
; !: alt
; ^: ctrl
; +: shift
; &: and
; <: only left, >: only right
; *: wildecard
; }}}
; IMPORTANT INFO ABOUT GETTING STARTED: Lines that start with a
; semicolon, such as this one, are comments.  They are not executed.

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

; For Vim Mode
GroupAdd VimGroup, ahk_class Notepad
GroupAdd VimGroup, ahk_class WordPadClass
GroupAdd VimGroup, 作成
VimMode=Insert
Vim_g=0
Vim_n=0
VimLineCopy=0

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

; Ref for IME: http://www6.atwiki.jp/eamat/pages/17.html
; Get IME Status. 0: Off, 1: On
IME_GET(WinTitle="A")  {
  ControlGet,hwnd,HWND,,,%WinTitle%
  if (WinActive(WinTitle)) {
    ptrSize := !A_PtrSize ? 4 : A_PtrSize
    VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
    NumPut(cbSize, stGTI,  0, "UInt")   ;   DWORD   cbSize;
    hwnd := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
        ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd
  }

  Return DllCall("SendMessage"
      , UInt, DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hwnd)
      , UInt, 0x0283  ;Message : WM_IME_CONTROL
      ,  Int, 0x0005  ;wParam  : IMC_GETOPENSTATUS
      ,  Int, 0)      ;lParam  : 0
}
; Get input status. 1: Converting, 2: Have converting window, 0: Others
IME_GetConverting(WinTitle="A",ConvCls="",CandCls="") {
  ; Input windows, candidate windows (Add new IME with "|")
  ConvCls .= (ConvCls ? "|" : "")                 ;--- Input Window ---
    .  "ATOK\d+CompStr"                           ; ATOK
    .  "|imejpstcnv\d+"                           ; MS-IME
    .  "|WXGIMEConv"                              ; WXG
    .  "|SKKIME\d+\.*\d+UCompStr"                 ; SKKIME Unicode
    .  "|MSCTFIME Composition"                    ; Google IME
  CandCls .= (CandCls ? "|" : "")                 ;--- Candidate Window ---
    .  "ATOK\d+Cand"                              ; ATOK
    .  "|imejpstCandList\d+|imejpstcand\d+"       ; MS-IME 2002(8.1)XP
    .  "|mscandui\d+\.candidate"                  ; MS Office IME-2007
    .  "|WXGIMECand"                              ; WXG
    .  "|SKKIME\d+\.*\d+UCand"                    ; SKKIME Unicode
 CandGCls := "GoogleJapaneseInputCandidateWindow" ; Google IME

  ControlGet,hwnd,HWND,,,%WinTitle%
  if (WinActive(WinTitle)) {
    ptrSize := !A_PtrSize ? 4 : A_PtrSize
    VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
    NumPut(cbSize, stGTI,  0, "UInt")   ;   DWORD   cbSize;
    hwnd := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
      ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd
  }

  WinGet, pid, PID,% "ahk_id " hwnd
  tmm:=A_TitleMatchMode
  SetTitleMatchMode, RegEx
  ret := WinExist("ahk_class " . CandCls . " ahk_pid " pid) ? 2
      :  WinExist("ahk_class " . CandGCls                 ) ? 2
      :  WinExist("ahk_class " . ConvCls . " ahk_pid " pid) ? 1
      :  0
  SetTitleMatchMode, %tmm%
  Return ret
}
; Set IME, SetSts=0: Off, 1: On, return 0 for success, others for non-success
IME_SET(SetSts=0, WinTitle="A")    {
  ControlGet,hwnd,HWND,,,%WinTitle%
  if(WinActive(WinTitle)){
    ptrSize := !A_PtrSize ? 4 : A_PtrSize
    VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
    NumPut(cbSize, stGTI,  0, "UInt")   ;   DWORD   cbSize;
    hwnd := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
        ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd
  }

  Return DllCall("SendMessage"
    , UInt, DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hwnd)
    , UInt, 0x0283  ;Message : WM_IME_CONTROL
    ,  Int, 0x006   ;wParam  : IMC_SETOPENSTATUS
    ,  Int, SetSts) ;lParam  : 0 or 1
}  

; }}}

; Vim mode {{{
#IfWInActive, ahk_group VimGroup
; Reset Modes {{{
VimSetMode(Mode="", g=0, n=0, LineCopy=-1) {
  global
  if(Mode!=""){
    VimMode=%Mode%
  }
  Vim_g=%g%
  Vim_n=%n%
  if (LineCopy!=-1) {
    VimLineCopy=%LineCopy%
  }
  VimCheckMode(0)
  Return
}
VimCheckMode(verbose=0) {
  global
  if(verbose=1){
    TrayTip,VimMode,%VimMode%,10,, ; 10 sec is minimum for TrayTip
  }else if(verbose=2){
    TrayTip,VimMode,%VimMode%`r`ng=%Vim_g%`r`nn=%Vim_n%,10,,
  }
  if(verbose=3){
    Msgbox,
    (
    VimMode: %VimMode%
    Vim_g: %Vim_g%
    Vim_n: %Vim_n%
    VimLineCopy: %VimLineCopy%
    )
  }
  Return
}
^!+c::
  VimCheckMode(3)
  Return
; }}}

; Enter vim normal mode {{{
#IfWInActive, ahk_group VimGroup
Esc:: ; Just send Esc at converting.
  if (IME_GET(A)) {
    if (IME_GetConverting(A)) {
      Send,{Esc}
    } else {
      IME_SET()
      VimSetMode("Normal")
    }
  } else {
    VimSetMode("Normal")
  }
  Return

^[:: ; Go to Normal mode (for vim) with IME off even at converting.
  if (IME_GET(A)) {
    Send,{Esc}
    Sleep 1
    IME_SET()
  }
  VimSetMode("Normal")
  Return
; }}}

; Enter vim insert mode (Exit vim normal mode) {{{
#If WInActive("ahk_group VimGroup") && (VimMode == "Normal")
i::VimSetMode("Insert")
+i::
  Send,{Home}
  VimSetMode("Insert")
  Return
a::
  Send,{Right}
  VimSetMode("Insert")
  Return
+a::
  Send,{End}
  VimSetMode("Insert")
  Return
o::
  Send,{End}{Enter}
  VimSetMode("Insert")
  Return
+o::
  Send,{Up}{End}{Enter}
  VimSetMode("Insert")
  Return
; }}}

; Repeat {{{
#If WInActive("ahk_group VimGroup") and (VimMode != "Insert") and (Vim_n=0)
;0::VimSetMode("",0,0)
1::VimSetMode("",0,1)
2::VimSetMode("",0,2)
3::VimSetMode("",0,3)
4::VimSetMode("",0,4)
5::VimSetMode("",0,5)
6::VimSetMode("",0,6)
7::VimSetMode("",0,7)
8::VimSetMode("",0,8)
9::VimSetMode("",0,9)
#If WInActive("ahk_group VimGroup") and (VimMode != "Insert") and (Vim_n=1)
0::VimSetMode("",0,10)
1::VimSetMode("",0,11)
2::VimSetMode("",0,12)
3::VimSetMode("",0,13)
4::VimSetMode("",0,14)
5::VimSetMode("",0,15)
6::VimSetMode("",0,16)
7::VimSetMode("",0,17)
8::VimSetMode("",0,18)
9::VimSetMode("",0,19)
#If WInActive("ahk_group VimGroup") and (VimMode != "Insert") and (Vim_n=2)
0::VimSetMode("",0,20)
1::VimSetMode("",0,21)
2::VimSetMode("",0,22)
3::VimSetMode("",0,23)
4::VimSetMode("",0,24)
5::VimSetMode("",0,25)
6::VimSetMode("",0,26)
7::VimSetMode("",0,27)
8::VimSetMode("",0,28)
9::VimSetMode("",0,29)
#If WInActive("ahk_group VimGroup") and (VimMode != "Insert") and (Vim_n=3)
0::VimSetMode("",0,30)
1::VimSetMode("",0,31)
2::VimSetMode("",0,32)
3::VimSetMode("",0,33)
4::VimSetMode("",0,34)
5::VimSetMode("",0,35)
6::VimSetMode("",0,36)
7::VimSetMode("",0,37)
8::VimSetMode("",0,38)
9::VimSetMode("",0,39)
#If WInActive("ahk_group VimGroup") and (VimMode != "Insert") and (Vim_n=4)
0::VimSetMode("",0,40)
1::VimSetMode("",0,41)
2::VimSetMode("",0,42)
3::VimSetMode("",0,43)
4::VimSetMode("",0,44)
5::VimSetMode("",0,45)
6::VimSetMode("",0,46)
7::VimSetMode("",0,47)
8::VimSetMode("",0,48)
9::VimSetMode("",0,49)
#If WInActive("ahk_group VimGroup") and (VimMode != "Insert") and (Vim_n=5)
0::VimSetMode("",0,50)
1::VimSetMode("",0,51)
2::VimSetMode("",0,52)
3::VimSetMode("",0,53)
4::VimSetMode("",0,54)
5::VimSetMode("",0,55)
6::VimSetMode("",0,56)
7::VimSetMode("",0,57)
8::VimSetMode("",0,58)
9::VimSetMode("",0,59)
#If WInActive("ahk_group VimGroup") and (VimMode != "Insert") and (Vim_n=6)
0::VimSetMode("",0,60)
1::VimSetMode("",0,61)
2::VimSetMode("",0,62)
3::VimSetMode("",0,63)
4::VimSetMode("",0,64)
5::VimSetMode("",0,65)
6::VimSetMode("",0,66)
7::VimSetMode("",0,67)
8::VimSetMode("",0,68)
9::VimSetMode("",0,69)
#If WInActive("ahk_group VimGroup") and (VimMode != "Insert") and (Vim_n=7)
0::VimSetMode("",0,70)
1::VimSetMode("",0,71)
2::VimSetMode("",0,72)
3::VimSetMode("",0,73)
4::VimSetMode("",0,74)
5::VimSetMode("",0,75)
6::VimSetMode("",0,76)
7::VimSetMode("",0,77)
8::VimSetMode("",0,78)
9::VimSetMode("",0,79)
#If WInActive("ahk_group VimGroup") and (VimMode != "Insert") and (Vim_n=8)
0::VimSetMode("",0,80)
1::VimSetMode("",0,81)
2::VimSetMode("",0,82)
3::VimSetMode("",0,83)
4::VimSetMode("",0,84)
5::VimSetMode("",0,85)
6::VimSetMode("",0,86)
7::VimSetMode("",0,87)
8::VimSetMode("",0,88)
9::VimSetMode("",0,89)
#If WInActive("ahk_group VimGroup") and (VimMode != "Insert") and (Vim_n=9)
0::VimSetMode("",0,90)
1::VimSetMode("",0,91)
2::VimSetMode("",0,92)
3::VimSetMode("",0,93)
4::VimSetMode("",0,94)
5::VimSetMode("",0,95)
6::VimSetMode("",0,96)
7::VimSetMode("",0,97)
8::VimSetMode("",0,98)
9::VimSetMode("",0,99)
#If WInActive("ahk_group VimGroup") and (VimMode != "Insert") and (Vim_n>=10)
0::VimSetMode("",0,0)
1::VimSetMode("",0,0)
2::VimSetMode("",0,0)
3::VimSetMode("",0,0)
4::VimSetMode("",0,0)
5::VimSetMode("",0,0)
6::VimSetMode("",0,0)
7::VimSetMode("",0,0)
8::VimSetMode("",0,0)
9::VimSetMode("",0,0)
; }}}

; g {{{
#If WInActive("ahk_group VimGroup") and (VimMode != "Insert") and (not Vim_g)
g::VimSetMode("",1)
; }}}

; Normal Mode Basic {{{
#If WInActive("ahk_group VimGroup") and (VimMode == "Normal")
; Undo/Redo
u::Send,^z
^r::Send,^y

; Combine lines
+j::Send,{Down}{Home}{BS}{Space}{Left}
; }}}

; Move {{{
VimMove(key="", shift=0){
  global
  ; 1 character
  if (key="h" and shift=0){
    Send,{Left}
  } else if (key="h" and shift=1){
    Send,+{Left}
  }else if (key="j" and shift=0){
    Send,{Down}
  } else if (key="j" and shift=1){
    Send,+{Down}
  }else if (key="k" and shift=0){
    Send,{Up}
  } else if (key="k" and shift=1){
    Send,+{Up}
  }else if (key="l" and shift=0){
    Send,{Right}
  } else if (key="l" and shift=1){
    Send,+{Right}
  ; Home/End
  }else if (key="0" and shift=0){
    Send,{Home}
  } else if (key="0" and shift=1){
    Send,+{Home}
  }else if (key="+4" and shift=0){
    Send,{End}
  } else if (key="+4" and shift=1){
    Send,+{End}
  }else if (key="^" and shift=0){
    Send,{End}^{Right}
  } else if (key="^" and shift=1){
    Send,+{End}+^{Right}
  ; Words
  }else if (key="w" and shift=0){
    Send,^{Right}
  } else if (key="w" and shift=1){
    Send,+^{Right}
  }else if (key="b" and shift=0){
    Send,^{Left}
  } else if (key="b" and shift=1){
    Send,+^{Left}
  ; Page Up/Down
  }else if (key="^u" and shift=0){
    Send,{Up 10}
  } else if (key="^u" and shift=1){
    Send,+{Up 10}
  }else if (key="^d" and shift=0){
    Send,{Down 10}
  } else if (key="^u" and shift=1){
    Send,+{Down 10}
  }else if (key="^b" and shift=0){
    Send,{PgUp}
  } else if (key="^b" and shift=1){
    Send,+{PgUp}
  }else if (key="^f" and shift=0){
    Send,{PgDown}
  } else if (key="^f" and shift=1){
    Send,+{PgDown}
  }else if (key="g" and shift=0){
    Send,^{Home}
  } else if (key="g" and shift=1){
    Send,+^{Home}
  }else if (key="+g" and shift=0){
    ;Send,^{End}{Home}
    Send,^{End}
  } else if (key="+g" and shift=1){
    ;Send,+^{End}+{Home}
    Send,+^{End}
  }
  VimSetMode("",0,0)
}
VimMoveLoop(key="", shift=0){
  global
  if (Vim_n = 0) {
    Vim_n=1
  }
  Loop, %Vim_n% {
    VimMove(key,shift)
  }
}

#If WInActive("ahk_group VimGroup") and (VimMode == "Normal")
; 1 character
h::VimMoveLoop("h")
j::VimMoveLoop("j")
k::VimMoveLoop("k")
l::VimMoveLoop("l")
^h::VimMoveLoop("h")
^j::VimMoveLoop("j")
^k::VimMoveLoop("k")
^l::VimMoveLoop("l")
; Home/End
0::VimMoveLoop("0")
+4::VimMoveLoop("+4")
^a::VimMoveLoop("0") ; Emacs like
^e::VimMoveLoop("+4") ; Emacs like
^::VimMoveLoop("^")
; Words
w::VimMoveLoop("w")
+w::VimMoveLoop("w") ; +w/e/+e are same as w
e::VimMoveLoop("w")
+e::VimMoveLoop("w")
b::VimMoveLoop("b")
+b::VimMoveLoop("b") ; +b = b
; Page Up/Down
^u::VimMoveLoop("^u")
^d::VimMoveLoop("^d")
^b::VimMoveLoop("^b")
^f::VimMoveLoop("^f")
; gg
#If WInActive("ahk_group VimGroup") and (VimMode="Normal") and (Vim_g)
g::VimMoveLoop("g")
; G
#If WInActive("ahk_group VimGroup") and (VimMode="Normal")
+g::VimMoveLoop("+g")
; }}} Move

; Copy/Cut/Paste (ydcxp){{{
#If WInActive("ahk_group VimGroup") and (VimMode="Normal")
; YDC
VimYDC(key="line"){
  global
  if (key="line"){
    VimLineCopy=1
    Send,{Home}+{Down}
  }else if (key="j"){
    VimLineCopy=1
    VimMoveLoop("j",1)
  }else if (key="k"){
    VimLineCopy=1
    Send,{Home}{Down}+{Up}
    VimMoveLoop("k",1)
  }else{
    VimLineCopy=0
    VimMoveLoop(key,1)
  }
  if (VimMode="y"){
    Send,^c
    VimSetMode("Normal")
  }else if (VimMode="d"){
    Send,^x
    VimSetMode("Normal")
  }else if (VimMode="c"){
    Send,^x
    VimSetMode("Insert")
  }
  Return
}

; YDC
#If WInActive("ahk_group VimGroup") and (VimMode="Normal")
+y::
  VimSetMode("y")
  VimYDC("line")
  Return
y::VimSetMode("y")
+d::
  VimSetMode("d")
  VimYDC("+4")
  Return
d::VimSetMode("d")
+c::
  VimSetMode("c")
  VimYDC("+4")
  Return
c::VimSetMode("c")
#If WInActive("ahk_group VimGroup") and (VimMode="y")
y::VimYDC("line")
#If WInActive("ahk_group VimGroup") and (VimMode="d")
d::VimYDC("line")
#If WInActive("ahk_group VimGroup") and (VimMode="c")
c::VimYDC("line")
#If WInActive("ahk_group VimGroup") and ( (VimMode="y") or (VimMode="d") or (VimMode="c"))
j::VimYDC("j")
k::VimYDC("k")
+4::VimYDC("+4")
0::VimYDC("0")
w::VimYDC("w")
+w::VimYDC("w")
e::VimYDC("w")
+e::VimYDC("w")
b::VimYDC("b")
+b::VimYDC("b")
+g::VimYDC("+g")

#If WInActive("ahk_group VimGroup") and (VimMode="Normal")
; X
x::Send, {Delete}
+x::Send, {BS}

; Paste
#If WInActive("ahk_group VimGroup") and (VimMode="Normal")
p::
  i:=0
  ;Send, {p Up}
  Loop {
    if !GetKeyState("p", "P"){
      break
    }
    if VimLineCopy {
      Send,{End}{Enter}^v{BS}{Home}
    } else {
      Send,{Right}
      Send,^v
      ;Sleep,1000
      Send,^{Left}
    }
    ;TrayTip,i,%i%,
    if(i=0){
      Sleep, 500
    }else if(i>100){
      Msgbox Stop at 100!!!
      break
    }else{
      Sleep, 0
    }
    i+=1
    break
  }
  KeyWait, p ; To avoid repeat, somehow it calls <C-p>, print...
  Return
+p::
  if VimLineCopy {
    Send,{Up}{End}{Enter}^v{BS}{Home}
  } else {
    Send,^v^{Left}
  }
  KeyWait, p
  Return
; }}} Copy/Cut/Paste (ydcxp)

; Vim visual mode {{{

; Visual Char
#If WInActive("ahk_group VimGroup") and (VimMode="Normal")
v::VimSetMode("VisualChar")
#If WInActive("ahk_group VimGroup") and (VimMode="VisualChar")
; 1 character
h::VimMoveLoop("h",1)
j::VimMoveLoop("j",1)
k::VimMoveLoop("k",1)
l::VimMoveLoop("l",1)
^h::VimMoveLoop("h",1)
^j::VimMoveLoop("j",1)
^k::VimMoveLoop("k",1)
^l::VimMoveLoop("l",1)
; Home/End
0::VimMoveLoop("0",1)
+4::VimMoveLoop("+4",1)
^a::VimMoveLoop("0") ; Emacs lik,1e
^e::VimMoveLoop("+4") ; Emacs lik,1e
^::VimMoveLoop("^",1)
; Words
w::VimMoveLoop("w",1)
+w::VimMoveLoop("w") ; +w/e/+e are same as ,1w
e::VimMoveLoop("w",1)
+e::VimMoveLoop("w",1)
b::VimMoveLoop("b",1)
+b::VimMoveLoop("b") ; +b = ,1b
; Page Up/Down
^u::VimMoveLoop("^u",1)
^d::VimMoveLoop("^d",1)
^b::VimMoveLoop("^b",1)
^f::VimMoveLoop("^f",1)
; gg
#If WInActive("ahk_group VimGroup") and (VimMode="VisualChar") and (Vim_g)
g::VimMoveLoop("g",1)
; G
#If WInActive("ahk_group VimGroup") and (VimMode="VisualChar")
+g::VimMoveLoop("+g",1)
; ydc
#If WInActive("ahk_group VimGroup") and (VimMode="VisualChar")
y::
  Send,^c
  VimSetMode("Normal",0,0,0)
  Return
d::
  Send,^x
  VimSetMode("Normal",0,0,0)
  Return
x::
  Send,^x
  VimSetMode("Normal",0,0,0)
  Return
c::
  Send,^x
  VimSetMode("Insert",0,0,0)
  Return

; Visual Line
#If WInActive("ahk_group VimGroup") and (VimMode="Normal")
+v::
  VimSetMode("VisualLineFirst")
  Send,{Home}+{Down}
  Return
#If WInActive("ahk_group VimGroup") and (InStr(VimMode,"VisualLine"))
VimMoveVisualLine(key="",up=0){
  global
  if (VimMode="VisualLineFirst") and (up=1){
    Send,{End}{Home}+{Up}
  }
  VimMoveLoop(key,1)
  VimSetMode("VisualLine")
}
; 1 character
j::VimMoveVisualLine("j",0)
k::VimMoveVisualLine("k",1)
^j::VimMoveVisualLine("j",0)
^k::VimMoveVisualLine("k",1)
; Page Up/Down
^u::VimMoveVisualLine("^u",1)
^d::VimMoveVisualLine("^d",0)
^b::VimMoveVisualLine("^b",1)
^f::VimMoveVisualLine("^f",0)
; gg
#If WInActive("ahk_group VimGroup") and (InStr(VimMode,"VisualLine")) and (vim_g)
g::VimMoveVisualLine("g",1)
; G
#If WInActive("ahk_group VimGroup") and (InStr(VimMode,"VisualLine"))
+g::VimMoveLoop("+g",0)
; ydc
#If WInActive("ahk_group VimGroup") and (InStr(VimMode,"VisualLine"))
y::
  Send,^c
  VimSetMode("Normal",0,0,1)
  Return
d::
  Send,^x
  VimSetMode("Normal",0,0,1)
  Return
x::
  Send,^x
  VimSetMode("Normal",0,0,1)
  Return
c::
  Send,^x
  VimSetMode("Insert",0,0,1)
  Return

; }}} Vim visual mode

; Search {{{
#If WInActive("ahk_group VimGroup") and (VimMode="Normal")
/::Send,^f
n::Send,{F3}
+n::Send,+{F3}
; }}} Search

; Vim comamnd mode {{{
#If WInActive("ahk_group VimGroup") and (VimMode="Normal")
+`;::VimSetMode("Comments") ;(:)
;vkBAsc028::VimSetMode("Comments") ; colon(:) for JIS

; }}} Vim command mode

;;;  # Make Upcase
;;;  if ( USE104 )
;;;    key L0-S-BackQuote = S-Right C-x &Wait(50) &ClipboardUpcaseWord C-v
;;;    key L0-S-E0BackQuote = S-Right C-x &Wait(50) &ClipboardUpcaseWord C-v
;;;  else
;;;    key L0-S-Caret = S-Right C-x &Wait(50) &ClipboardUpcaseWord C-v
;;;  endif
;;;  key L0-S-n = S-F3
;;;
;;;  # Save/Quit
;;;keymap2 VimZ: Global = &Ignore
;;;  key L0-S-z = C-s A-F4
;;;  key L0-S-q = A-F4
;;;
;;;keymap Vim : Global
;;;  key L0-S-z = &Prefix(VimZ)
;;;
;;;  # Overwrite
;;;  key L0-r = $InOO
;;;  key L0-S-r = $InOC
;;;
;;;  key L5-*S-a = Delete *S-a $InN
;;;  key L5-*S-b = Delete *S-b $InN
;;;  key L5-*S-c = Delete *S-c $InN
;;;  key L5-*S-d = Delete *S-d $InN
;;;  key L5-*S-e = Delete *S-e $InN
;;;  key L5-*S-f = Delete *S-f $InN
;;;  key L5-*S-g = Delete *S-g $InN
;;;  key L5-*S-h = Delete *S-h $InN
;;;  key L5-*S-i = Delete *S-i $InN
;;;  key L5-*S-j = Delete *S-j $InN
;;;  key L5-*S-k = Delete *S-k $InN
;;;  key L5-*S-l = Delete *S-l $InN
;;;  key L5-*S-m = Delete *S-m $InN
;;;  key L5-*S-n = Delete *S-n $InN
;;;  key L5-*S-o = Delete *S-o $InN
;;;  key L5-*S-p = Delete *S-p $InN
;;;  key L5-*S-q = Delete *S-q $InN
;;;  key L5-*S-r = Delete *S-r $InN
;;;  key L5-*S-s = Delete *S-s $InN
;;;  key L5-*S-t = Delete *S-t $InN
;;;  key L5-*S-u = Delete *S-u $InN
;;;  key L5-*S-v = Delete *S-v $InN
;;;  key L5-*S-w = Delete *S-w $InN
;;;  key L5-*S-x = Delete *S-x $InN
;;;  key L5-*S-y = Delete *S-y $InN
;;;  key L5-*S-z = Delete *S-z $InN
;;;  key L5-*S-_0 = Delete *S-_0 $InN
;;;  key L5-*S-_1 = Delete *S-_1 $InN
;;;  key L5-*S-_2 = Delete *S-_2 $InN
;;;  key L5-*S-_3 = Delete *S-_3 $InN
;;;  key L5-*S-_4 = Delete *S-_4 $InN
;;;  key L5-*S-_5 = Delete *S-_5 $InN
;;;  key L5-*S-_6 = Delete *S-_6 $InN
;;;  key L5-*S-_7 = Delete *S-_7 $InN
;;;  key L5-*S-_8 = Delete *S-_8 $InN
;;;  key L5-*S-_9 = Delete *S-_9 $InN
;;;  key L5-*S-Comma = Delete *S-Comma $InN
;;;  key L5-*S-Period = Delete *S-Period $InN
;;;  key L5-*S-HyphenMinus = Delete *S-HyphenMinus $InN
;;;  key L5-*S-LeftSquareBracket = Delete *S-LeftSquareBracket $InN
;;;  key L5-*S-RightSquareBracket = Delete *S-RightSquareBracket $InN
;;;  key L5-*S-Semicolon = Delete *S-Semicolon $InN
;;;  key L5-*S-BackSlash = Delete *S-BackSlash $InN
;;;  key L5-*S-Slash = Delete *S-Slash $InN
;;;  key L5-*S-Space = Delete *S-Space $InN
;;;  if ( USE104 )
;;;    key L5-*S-EqualsSign = Delete *S-EqualsSign $InN
;;;    key L5-*S-GraveAccent = Delete *S-GraveAccent $InN
;;;  else
;;;    key L5-*S-Caret = Delete *S-Caret $InN
;;;    key L5-*S-Atmark = Delete *S-Atmark $InN
;;;    key L5-*S-Colon = Delete *S-Colon $InN
;;;  endif
;;;
;;;  key L6-*S-a = Delete *S-a
;;;  key L6-*S-b = Delete *S-b
;;;  key L6-*S-c = Delete *S-c
;;;  key L6-*S-e = Delete *S-e
;;;  key L6-*S-d = Delete *S-d
;;;  key L6-*S-f = Delete *S-f
;;;  key L6-*S-g = Delete *S-g
;;;  key L6-*S-h = Delete *S-h
;;;  key L6-*S-i = Delete *S-i
;;;  key L6-*S-j = Delete *S-j
;;;  key L6-*S-k = Delete *S-k
;;;  key L6-*S-l = Delete *S-l
;;;  key L6-*S-m = Delete *S-m
;;;  key L6-*S-n = Delete *S-n
;;;  key L6-*S-o = Delete *S-o
;;;  key L6-*S-p = Delete *S-p
;;;  key L6-*S-q = Delete *S-q
;;;  key L6-*S-r = Delete *S-r
;;;  key L6-*S-s = Delete *S-s
;;;  key L6-*S-t = Delete *S-t
;;;  key L6-*S-u = Delete *S-u
;;;  key L6-*S-v = Delete *S-v
;;;  key L6-*S-w = Delete *S-w
;;;  key L6-*S-x = Delete *S-x
;;;  key L6-*S-y = Delete *S-y
;;;  key L6-*S-z = Delete *S-z
;;;  key L6-*S-_0 = Delete *S-_0
;;;  key L6-*S-_1 = Delete *S-_1
;;;  key L6-*S-_2 = Delete *S-_2
;;;  key L6-*S-_3 = Delete *S-_3
;;;  key L6-*S-_4 = Delete *S-_4
;;;  key L6-*S-_5 = Delete *S-_5
;;;  key L6-*S-_6 = Delete *S-_6
;;;  key L6-*S-_7 = Delete *S-_7
;;;  key L6-*S-_8 = Delete *S-_8
;;;  key L6-*S-_9 = Delete *S-_9
;;;  key L6-*S-Comma = Delete *S-Comma
;;;  key L6-*S-Period = Delete *S-Period
;;;  key L6-*S-HyphenMinus = Delete *S-HyphenMinus
;;;  key L6-*S-LeftSquareBracket = Delete *S-LeftSquareBracket
;;;  key L6-*S-RightSquareBracket = Delete *S-RightSquareBracket
;;;  key L6-*S-Semicolon = Delete *S-Semicolon
;;;  key L6-*S-BackSlash = Delete *S-BackSlash
;;;  key L6-*S-Slash = Delete *S-Slash
;;;  key L6-*S-Space = Delete *S-Space
;;;  if ( USE104 )
;;;    key L6-*S-EqualsSign = Delete *S-EqualsSign
;;;    key L6-*S-GraveAccent = Delete *S-GraveAccent
;;;  else
;;;    key L6-*S-Caret = Delete *S-Caret
;;;    key L6-*S-Atmark = Delete *S-Atmark
;;;    key L6-*S-Colon = Delete *S-Colon
;;;  endif
;;;
;;;  #}}}
;;;
;;;  # Command line mode {{{
;;;keymap2 VimCommandW: Global = &Ignore
;;;  key L0-Enter = C-s # Save
;;;  key L0-q = C-s A-F4 # Save & quit
;;;  key L0-Space = A-f a # Save as
;;;
;;;keymap2 VimCommandQ: Global = &Ignore
;;;  key L0-Enter = A-F4 # quit
;;;  #key L0-S-_1 = A-F4 n # quit!, makes problem when there is no change...
;;;
;;;keymap2 VimCommand: Global = &Ignore
;;;  key L0-w = &Prefix(VimCommandW)
;;;  key L0-q = &Prefix(VimCommandQ)
;;;  key L0-h = F1
;;;
;;;keymap Vim : Global
;;;  if ( USE104 )
;;;    key L0-S-Semicolon = &Prefix(VimCommand)
;;;  else
;;;    key L0-Scolon = &Prefix(VimCommand)
;;;  endif
;;;
;;;  #key L0-S-Semicolon = $InC $OutN
;;;  #key L7-w = A-f A-a # Save as
;;;  ##key L7-w = C-s # Save
;;;  #key L7-q = A-F4
;;;  #key L7-Enter = $OutC $InN
;;;  # }}}
;;;
;;;  # N * command {{{
;;;keymap2 VimRepeat: Vim = &Repeat((&KeymapWindow),100) &Variable(0,0)
;;;  key L0-y = &Prefix(VimCopy)
;;;  key L0-d = &Prefix(VimCut)
;;;  key L0-c = &Prefix(VimChange)
;;;
;;;keymap VimN0_9 : VimRepeat
;;;  key L0-_0 = &Variable(10,0) &Prefix(VimRepeat)
;;;  key L0-_1 = &Variable(10,1) &Prefix(VimRepeat)
;;;  key L0-_2 = &Variable(10,2) &Prefix(VimRepeat)
;;;  key L0-_3 = &Variable(10,3) &Prefix(VimRepeat)
;;;  key L0-_4 = &Variable(10,4) &Prefix(VimRepeat)
;;;  key L0-_5 = &Variable(10,5) &Prefix(VimRepeat)
;;;  key L0-_6 = &Variable(10,6) &Prefix(VimRepeat)
;;;  key L0-_7 = &Variable(10,7) &Prefix(VimRepeat)
;;;  key L0-_8 = &Variable(10,8) &Prefix(VimRepeat)
;;;  key L0-_9 = &Variable(10,9) &Prefix(VimRepeat)
;;;
;;;keymap Vim : Global
;;;  key L0-_1 = &Variable(0,1) &Prefix(VimN0_9)
;;;  key L0-_2 = &Variable(0,2) &Prefix(VimN0_9)
;;;  key L0-_3 = &Variable(0,3) &Prefix(VimN0_9)
;;;  key L0-_4 = &Variable(0,4) &Prefix(VimN0_9)
;;;  key L0-_5 = &Variable(0,5) &Prefix(VimN0_9)
;;;  key L0-_6 = &Variable(0,6) &Prefix(VimN0_9)
;;;  key L0-_7 = &Variable(0,7) &Prefix(VimN0_9)
;;;  key L0-_8 = &Variable(0,8) &Prefix(VimN0_9)
;;;  key L0-_9 = &Variable(0,9) &Prefix(VimN0_9)
;;;
;;;  # }}}
;;;
;#IfWInActive
;; }}} Vim mode

; Terminal/Vim {{{
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

; Other than Terminal/Vim {{{
#IfWInNotActive, ahk_group Terminal
^[::Send,{Esc}             ; Always C-[ to ESC, like vim
#IfWInNotActive
; }}}
; }}}

; For powerpoint {{{
#IfWInActive, ahk_class PP12FrameClass
^Space::Send,{Right}+{Left}
^=::Send,^tb{Enter}
^+=::Send,^tp{Enter}
; for JP keyboards
;^-::Send,^tb{Enter}
;^+-::Send,^tp{Enter}
^+s::Send,^tfsymbol{Enter}
^+a::Send,^tfarialEnter
^+h::Send,^tfhelveticaEnter
#IfWInActive
; }}}

; For word {{{
#IfWInActive, ahk_class OpusApp
^Space::Send,{Right}+{Left}
^=::Send,^tb{Enter}
^+=::Send,^tp{Enter}
; for JP keyboards
;^-::Send,^tb{Enter}
;^+-::Send,^tp{Enter}
#IfWInActive
; }}}

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
    msgbox, "A-S-Tab"
    ;Send,^+{Tab} ; dosen't work ()
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
; }}}

; Cursor, Mouse, Window move/size {{{
; Cursor {{{
!^h::Send,{Left}
!^j::Send,{Down}
!^k::Send,{Up}
!^l::Send,{Right}
; }}}

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
  ;MouseMove, 50, 50, 0
  MouseClick, Right
  Return

; Mouse wheel
!^m::MouseClick, WheelDown,,,  2
!^,::MouseClick, WheelUp,,,  2
; }}}

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
; }}}

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
; }}}
; }}} Cursor, Mouse, Window move

; For explorer {{{
#IfWInActive, ahk_class CabinetWClas
^o::Send,!{Left}
^i::Send,!{Right}
#IfWInActive
; }}}
