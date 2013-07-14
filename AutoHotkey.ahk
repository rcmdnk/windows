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
GroupAdd VimGroup, ahk_class NotePad
GroupAdd VimGroup, ahk_class WordPadClass
GroupAdd VimGroup, 作成
VimMode="Insert"
Vim_g=0
Vim_n=1
VimLineCopy=0

return
; }}}

; Basic HotKey/Function {{{
; Suspend
Tab & Esc::Suspend

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

  return DllCall("SendMessage"
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
  return ret
}
; }}}

; Vim mode {{{
#IfWInActive, ahk_group VimGroup
; Reset Modes {{{
VimResetMode(Normal=1, ResetLineCopy=0) {
  global
  if Normal {
    VimMode="Normal"
  } else {
    VimMode="Insert"
  }
  Vim_g=0
  Vim_n=1
  if ResetLineCopy {
    VimLineCopy=0
  }
  ;VimCheckMode()
  return
}

VimCheckMode() {
  global
  Msgbox,
  (
  VimMode: %VimMode%
  Vim_g: %Vim_g%
  Vim_n: %Vim_n%
  VimLineCopy: %VimLineCopy%
  )
  return
}
^!+c::VimCheckMode()
; }}}

; Enter vim normal mode {{{
#IfWInActive, ahk_group VimGroup
Esc:: ; Just send Esc at converting.
  Msgbox Enter Vim!
  VimCheckMode()
  if (IME_GET(A)) {
    if (IME_GetConverting(A)) {
      Send {Esc}
    } else {
      Send {vkF3sc029}
      VimResetMode(1)
    }
  } else {
    VimResetMode(1)
  }
  return
^[:: ; Go to Normal mode (for vim) with IME off even at converting.
  Msgbox Enter Vim!
  VimCheckMode()
  if (IME_GET(A)) {
    Send {vkF3sc029}, {Esc}
    VimResetMode(1)
  } else {
    VimResetMode(1)
  }
  return
; }}}

; Enter vim insert mode (Exit vim normal mode) {{{
#If WInActive("ahk_group VimGroup") and (VimMode="Normal")
i::VimResetMode(0)
+i::
  Send {Home}
  VimResetMode(0)
  return
a::
  Send {Right}
  VimResetMode(0)
  return
+a::
  Send {End}
  VimResetMode(0)
  return
o::
  Send {End}, {Enter}
  VimResetMode(0)
  return
+o::
  Send {Up}, {End}, {Enter}
  VimResetMode(0)
  return
; }}}

; Repeat {{{
#If WInActive("ahk_group VimGroup") and (VimMode != "Insert")
2::Vim_n=2
3::Vim_n=3
4::Vim_n=4
5::Vim_n=5
6::Vim_n=6
7::Vim_n=7
8::Vim_n=8
9::Vim_n=9
; }}}

; g {{{
#If WInActive("ahk_group VimGroup") and (VimMode != "Insert") and (not Vim_g)
g::global Vim_g=1
; }}}

; Normal Mode Basic {{{
#If WInActive("ahk_group VimGroup") and (VimMode = "Normal")
; Undo/Redo
u::Send ^z
^r::Send ^y

; Combine lines
+j::Send {Down}, {Home}, {BS}, {Space}, {Left}
; }}}

; Move {{{
VimMove(key="", shift=0){
  ; 1 character
  if (key=h and shift=0){
    Send {Left}
  } else if (key=h and shift=1){
    Send +{Left}
  }else if (key=j and shift=0){
    Send {Down}
  } else if (key=j and shift=1){
    Send +{Down}
  }else if (key=k and shift=0){
    Send {Up}
  } else if (key=k and shift=1){
    Send +{Up}
  ; Home/End
  }else if (key="0" and shift=0){
    Send {Home}
  } else if (key="0" and shift=1){
    Send +{Home}
  }else if (key="+4" and shift=0){
    Send {End}
  } else if (key="+4" and shift=1){
    Send +{End}
  ; Words
  }else if (key="w" and shift=0){
    Send ^{Right}
  } else if (key="w" and shift=1){
    Send ^+{Right}
  }else if (key="b" and shift=0){
    Send ^{Left}
  } else if (key="b" and shift=1){
    Send ^+{Left}
  ; Page Up/Down
  }else if (key="^u" and shift=0){
    Send {Up 10}
  } else if (key="^u" and shift=1){
    Send +{Up 10}
  }else if (key="^d" and shift=0){
    Send {Down 10}
  } else if (key="^u" and shift=1){
    Send +{Down 10}
  }else if (key="^b" and shift=0){
    Send {PgUp}
  } else if (key="^b" and shift=1){
    Send +{PgUp}
  }else if (key="^f" and shift=0){
    Send {PgDown}
  } else if (key="^f" and shift=1){
    Send +{PgDown}
  }else if (key="g" and shift=0){
    Send ^{Home}
  } else if (key="g" and shift=1){
    Send ^+{Home}
  }else if (key="+g" and shift=0){
    Send ^{End}
  } else if (key="+g" and shift=1){
    Send ^+{End}
  }
  global Vim_g=0
}
VimMoveLoop(key="", shift=0){
  global
  Loop Vim_n {
    VimMove(key,shift)
  }
  Vim_n=1
}

#If WInActive("ahk_group VimGroup")
a::Msgbox VimGroup
#If (VimMode = "Normal")
b::Msgbox Normal
#If WInActive("ahk_group VimGroup") and (VimMode = "Normal")
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
#If WInActive("ahk_group VimGroup") and (VimMode!="Insert") and (Vim_g)
g::VimMoveLoop("g")
; G
#If WInActive("ahk_group VimGroup") and (VimMode="Normal")
+g::VimMoveLoop("+g")
; }}}

; Copy/Cut/Paste (ydcxp){{{
#If WInActive("ahk_group VimGroup") and (VimMode="Normal")
; YDC
VimYDC(key="line"){
  if (key="line"){
    VimLineCopy=1
    Send {Home}, +{Down}
  }else if (key="j"){
    VimLineCopy=1
    VimMoveLoop("j",1)
  }else if (key="k"){
    VimLineCopy=1
    Send {Home}, {Down}, +{Up}
    VimMoveLoop("k",1)
  }else{
    VimLineCopy=0
    VimMoveLoop(key,1)
  }
  if (VimMode="y"){
    Send ^c
    VimResetMode(1)
  }else if (VimMode="d"){
    Send ^x
    VimResetMode(1)
  }else if (VimMode="c"){
    Send ^x
    VimResetMode(0)
  }
  return
}

;Y
#If WInActive("ahk_group VimGroup") and (VimMode="Normal")
+y::VimYDC("line")
y::VimMode=y
+d::VimYDC("^$")
d::VimMode=d
+c::VimYDC("^$")
c::VimMode=c
#If WInActive("ahk_group VimGroup") and (VimMode="y")
y::VimYDC("line")
#If WInActive("ahk_group VimGroup") and (VimMode="d")
d::VimYDC("^$")
#If WInActive("ahk_group VimGroup") and (VimMode="c")
c::VimYDC("^$")
#If WInActive("ahk_group VimGroup") and ( (VimMode="y") or (VimMode="d") or (VimMode="c"))
j::VimYDC("j")
k::VimYDC("k")
^4::VimYDC("^4")
0::VimYDC("0")
w::VimYDC("w")
+w::VimYDC("w")
e::VimYDC("w")
+e::VimYDC("w")
b::VimYDC("b")
+b::VimYDC("b")
+g::VimYDC("+g")

;Paste
p::
  if VimLineCopy {
    Send {End}, {Enter}, ^v, {Home}
  } else {
    Send {Right}, ^v, ^{Left}
  }
  return
+p::
  if VimLineCopy {
    Send {Up}, {End}, {Enter}, ^v, {Home}
  } else {
    Send ^v, ^{Left}
  }
  return

;;  # Search
;;  key L0-Slash = C-f
;;  key L0-n = F3
;;  key L0-S-n = S-F3
;;
;;  # Search window's definition
;;  # should be decided in each application
;;#window Search ( /window name/ || /検索(for example)/) : Vim
;;#  key L0-n = A-d A-f
;;#  key L0-S-n = A-u A-f
;;#  key L0-i = A-n $OutN
;;#  key Enter = $InN A-f A-F4
;;#  key L0-Enter = A-f A-F4
;;#  key L0-Esc = A-F4 $InN
;;#  key L0-C-LeftSquareBracket = A-F4 $InN
;;keymap Vim : Global
;;
;;  # Repeat
;;  key L0-Period = $WordSelect Delete $Paste Space
;;
;;  # Make Upcase
;;  if ( USE104 )
;;    key L0-S-BackQuote = S-Right C-x &Wait(50) &ClipboardUpcaseWord C-v
;;    key L0-S-E0BackQuote = S-Right C-x &Wait(50) &ClipboardUpcaseWord C-v
;;  else
;;    key L0-S-Caret = S-Right C-x &Wait(50) &ClipboardUpcaseWord C-v
;;  endif
;;  key L0-S-n = S-F3
;;
;;  # Save/Quit
;;keymap2 VimZ: Global = &Ignore
;;  key L0-S-z = C-s A-F4
;;  key L0-S-q = A-F4
;;
;;keymap Vim : Global
;;  key L0-S-z = &Prefix(VimZ)
;;
;;  # Overwrite
;;  key L0-r = $InOO
;;  key L0-S-r = $InOC
;;
;;  key L5-*S-a = Delete *S-a $InN
;;  key L5-*S-b = Delete *S-b $InN
;;  key L5-*S-c = Delete *S-c $InN
;;  key L5-*S-d = Delete *S-d $InN
;;  key L5-*S-e = Delete *S-e $InN
;;  key L5-*S-f = Delete *S-f $InN
;;  key L5-*S-g = Delete *S-g $InN
;;  key L5-*S-h = Delete *S-h $InN
;;  key L5-*S-i = Delete *S-i $InN
;;  key L5-*S-j = Delete *S-j $InN
;;  key L5-*S-k = Delete *S-k $InN
;;  key L5-*S-l = Delete *S-l $InN
;;  key L5-*S-m = Delete *S-m $InN
;;  key L5-*S-n = Delete *S-n $InN
;;  key L5-*S-o = Delete *S-o $InN
;;  key L5-*S-p = Delete *S-p $InN
;;  key L5-*S-q = Delete *S-q $InN
;;  key L5-*S-r = Delete *S-r $InN
;;  key L5-*S-s = Delete *S-s $InN
;;  key L5-*S-t = Delete *S-t $InN
;;  key L5-*S-u = Delete *S-u $InN
;;  key L5-*S-v = Delete *S-v $InN
;;  key L5-*S-w = Delete *S-w $InN
;;  key L5-*S-x = Delete *S-x $InN
;;  key L5-*S-y = Delete *S-y $InN
;;  key L5-*S-z = Delete *S-z $InN
;;  key L5-*S-_0 = Delete *S-_0 $InN
;;  key L5-*S-_1 = Delete *S-_1 $InN
;;  key L5-*S-_2 = Delete *S-_2 $InN
;;  key L5-*S-_3 = Delete *S-_3 $InN
;;  key L5-*S-_4 = Delete *S-_4 $InN
;;  key L5-*S-_5 = Delete *S-_5 $InN
;;  key L5-*S-_6 = Delete *S-_6 $InN
;;  key L5-*S-_7 = Delete *S-_7 $InN
;;  key L5-*S-_8 = Delete *S-_8 $InN
;;  key L5-*S-_9 = Delete *S-_9 $InN
;;  key L5-*S-Comma = Delete *S-Comma $InN
;;  key L5-*S-Period = Delete *S-Period $InN
;;  key L5-*S-HyphenMinus = Delete *S-HyphenMinus $InN
;;  key L5-*S-LeftSquareBracket = Delete *S-LeftSquareBracket $InN
;;  key L5-*S-RightSquareBracket = Delete *S-RightSquareBracket $InN
;;  key L5-*S-Semicolon = Delete *S-Semicolon $InN
;;  key L5-*S-BackSlash = Delete *S-BackSlash $InN
;;  key L5-*S-Slash = Delete *S-Slash $InN
;;  key L5-*S-Space = Delete *S-Space $InN
;;  if ( USE104 )
;;    key L5-*S-EqualsSign = Delete *S-EqualsSign $InN
;;    key L5-*S-GraveAccent = Delete *S-GraveAccent $InN
;;  else
;;    key L5-*S-Caret = Delete *S-Caret $InN
;;    key L5-*S-Atmark = Delete *S-Atmark $InN
;;    key L5-*S-Colon = Delete *S-Colon $InN
;;  endif
;;
;;  key L6-*S-a = Delete *S-a
;;  key L6-*S-b = Delete *S-b
;;  key L6-*S-c = Delete *S-c
;;  key L6-*S-e = Delete *S-e
;;  key L6-*S-d = Delete *S-d
;;  key L6-*S-f = Delete *S-f
;;  key L6-*S-g = Delete *S-g
;;  key L6-*S-h = Delete *S-h
;;  key L6-*S-i = Delete *S-i
;;  key L6-*S-j = Delete *S-j
;;  key L6-*S-k = Delete *S-k
;;  key L6-*S-l = Delete *S-l
;;  key L6-*S-m = Delete *S-m
;;  key L6-*S-n = Delete *S-n
;;  key L6-*S-o = Delete *S-o
;;  key L6-*S-p = Delete *S-p
;;  key L6-*S-q = Delete *S-q
;;  key L6-*S-r = Delete *S-r
;;  key L6-*S-s = Delete *S-s
;;  key L6-*S-t = Delete *S-t
;;  key L6-*S-u = Delete *S-u
;;  key L6-*S-v = Delete *S-v
;;  key L6-*S-w = Delete *S-w
;;  key L6-*S-x = Delete *S-x
;;  key L6-*S-y = Delete *S-y
;;  key L6-*S-z = Delete *S-z
;;  key L6-*S-_0 = Delete *S-_0
;;  key L6-*S-_1 = Delete *S-_1
;;  key L6-*S-_2 = Delete *S-_2
;;  key L6-*S-_3 = Delete *S-_3
;;  key L6-*S-_4 = Delete *S-_4
;;  key L6-*S-_5 = Delete *S-_5
;;  key L6-*S-_6 = Delete *S-_6
;;  key L6-*S-_7 = Delete *S-_7
;;  key L6-*S-_8 = Delete *S-_8
;;  key L6-*S-_9 = Delete *S-_9
;;  key L6-*S-Comma = Delete *S-Comma
;;  key L6-*S-Period = Delete *S-Period
;;  key L6-*S-HyphenMinus = Delete *S-HyphenMinus
;;  key L6-*S-LeftSquareBracket = Delete *S-LeftSquareBracket
;;  key L6-*S-RightSquareBracket = Delete *S-RightSquareBracket
;;  key L6-*S-Semicolon = Delete *S-Semicolon
;;  key L6-*S-BackSlash = Delete *S-BackSlash
;;  key L6-*S-Slash = Delete *S-Slash
;;  key L6-*S-Space = Delete *S-Space
;;  if ( USE104 )
;;    key L6-*S-EqualsSign = Delete *S-EqualsSign
;;    key L6-*S-GraveAccent = Delete *S-GraveAccent
;;  else
;;    key L6-*S-Caret = Delete *S-Caret
;;    key L6-*S-Atmark = Delete *S-Atmark
;;    key L6-*S-Colon = Delete *S-Colon
;;  endif
;;
;;  #}}}
;;
;;  # Vim visual mode {{{
;;  # Visual Mode Common
;;keymap2 VimVisual: Global = &Ignore
;;  key L1-*L2-*L3-*L4-g = S-C-Home # gg
;;keymap Vim : Global
;;
;;  key L1-*L2-*L3-*L4-h = S-Left
;;  key L1-*L2-*L3-*L4-j = S-Down
;;  key L1-*L2-*L3-*L4-k = S-Up
;;  key L1-*L2-*L3-*L4-l = S-Right
;;  key L1-*L2-*L3-*L4-_0 = S-Home
;;  key L1-*L2-*L3-*L4-S-_4 = S-End
;;  key L1-*L2-*L3-*L4-w = S-C-Right
;;  key L1-*L2-*L3-*L4-S-w = S-C-Right
;;  key L1-*L2-*L3-*L4-e = S-C-Right
;;  key L1-*L2-*L3-*L4-S-e = S-C-Right
;;  key L1-*L2-*L3-*L4-b = S-C-Left
;;  key L1-*L2-*L3-*L4-S-b = S-C-Left
;;  key L1-*L2-*L3-*L4-g = &Prefix(VimVisual)
;;  key L1-*L2-*L3-*L4-S-g = S-C-Home
;;
;;  key L1-*L2-*L3-*L4-C-u = &Variable(0,10) &Repeat((S-Up),10) &Variable(0,0)
;;  key L1-*L2-*L3-*L4-C-d = &Variable(0,10) &Repeat((S-Down),10) &Variable(0,0)
;;  key L1-*L2-*L3-*L4-C-b = PageUp
;;  key L1-*L2-*L3-*L4-C-f = PageDown
;;
;;  key L1-*L2-*L3-*L4-y = C-c $InN $OutL
;;  key L1-*L2-*L3-*L4-d = C-x $InN $OutL
;;  key L1-*L2-*L3-*L4-x = C-x $InN $OutL
;;  key L1-*L2-*L3-*L4-c = C-x $OutVC $OutL
;;
;;  #key L1-*L2-*L3-*L4-S-y = Home S-End C-c $InL
;;  #key L1-*L2-*L3-*L4-S-d = Home S-End C-x $InL
;;  #key L1-*L2-*L3-*L4-S-x = Home S-End C-x $InL
;;  #key L1-*L2-*L3-*L4-S-c = Home S-End C-x $OutVC $InL
;;  key L1-*L2-*L3-*L4-S-y = S-End C-c $InL
;;  key L1-*L2-*L3-*L4-S-d = S-End C-x $InL
;;  key L1-*L2-*L3-*L4-S-x = S-End C-x $InL
;;  key L1-*L2-*L3-*L4-S-c = S-End C-x $OutVC $InL
;;
;;  key L1-*L2-*L3-*L4-Esc = $InN
;;  key L1-*L2-*L3-*L4-C-LeftSquareBracket = $InN
;;
;;  key L1-*L2-*L3-L4-~L9-p = Delete $Paste C-Left $InN
;;  key L1-*L2-*L3-L4-~L9-S-p = Delete $Paste C-Left $InN
;;  key L1-*L2-*L3-L4-L9-p = Delete $Paste Home $InN
;;  key L1-*L2-*L3-L4-L9-S-p = Delete $Paste Home $InN
;;
;;  # Characterwise-visual L1+L2
;;  key L0-v = $InVC
;;
;;  # Linewise-visual L1+L3
;;  key L0-S-v = $InVL Home S-End
;;
;;  key L1-~L2-L3-~L4-j = S-Down S-End
;;  key L1-~L2-L3-~L4-k = S-Up S-Home
;;
;;  key L1-~L2-L3-~L4-y = C-c $InN $InL
;;  key L1-~L2-L3-~L4-d = C-x $InN $InL
;;  key L1-~L2-L3-~L4-x = C-x $InN $InL
;;  key L1-~L2-L3-~L4-c = C-x $OutVC $InL
;;
;;  # Blockwise-visual L1+L4
;;  key L0-C-v = C-b $InVB # This is available in TeraPad
;;
;;  # }}}
;;
;;  # Command line mode {{{
;;keymap2 VimCommandW: Global = &Ignore
;;  key L0-Enter = C-s # Save
;;  key L0-q = C-s A-F4 # Save & quit
;;  key L0-Space = A-f a # Save as
;;
;;keymap2 VimCommandQ: Global = &Ignore
;;  key L0-Enter = A-F4 # quit
;;  #key L0-S-_1 = A-F4 n # quit!, makes problem when there is no change...
;;
;;keymap2 VimCommand: Global = &Ignore
;;  key L0-w = &Prefix(VimCommandW)
;;  key L0-q = &Prefix(VimCommandQ)
;;  key L0-h = F1
;;
;;keymap Vim : Global
;;  if ( USE104 )
;;    key L0-S-Semicolon = &Prefix(VimCommand)
;;  else
;;    key L0-Scolon = &Prefix(VimCommand)
;;  endif
;;
;;  #key L0-S-Semicolon = $InC $OutN
;;  #key L7-w = A-f A-a # Save as
;;  ##key L7-w = C-s # Save
;;  #key L7-q = A-F4
;;  #key L7-Enter = $OutC $InN
;;  # }}}
;;
;;  # N * command {{{
;;keymap2 VimRepeat: Vim = &Repeat((&KeymapWindow),100) &Variable(0,0)
;;  key L0-y = &Prefix(VimCopy)
;;  key L0-d = &Prefix(VimCut)
;;  key L0-c = &Prefix(VimChange)
;;
;;keymap VimN0_9 : VimRepeat
;;  key L0-_0 = &Variable(10,0) &Prefix(VimRepeat)
;;  key L0-_1 = &Variable(10,1) &Prefix(VimRepeat)
;;  key L0-_2 = &Variable(10,2) &Prefix(VimRepeat)
;;  key L0-_3 = &Variable(10,3) &Prefix(VimRepeat)
;;  key L0-_4 = &Variable(10,4) &Prefix(VimRepeat)
;;  key L0-_5 = &Variable(10,5) &Prefix(VimRepeat)
;;  key L0-_6 = &Variable(10,6) &Prefix(VimRepeat)
;;  key L0-_7 = &Variable(10,7) &Prefix(VimRepeat)
;;  key L0-_8 = &Variable(10,8) &Prefix(VimRepeat)
;;  key L0-_9 = &Variable(10,9) &Prefix(VimRepeat)
;;
;;keymap Vim : Global
;;  key L0-_1 = &Variable(0,1) &Prefix(VimN0_9)
;;  key L0-_2 = &Variable(0,2) &Prefix(VimN0_9)
;;  key L0-_3 = &Variable(0,3) &Prefix(VimN0_9)
;;  key L0-_4 = &Variable(0,4) &Prefix(VimN0_9)
;;  key L0-_5 = &Variable(0,5) &Prefix(VimN0_9)
;;  key L0-_6 = &Variable(0,6) &Prefix(VimN0_9)
;;  key L0-_7 = &Variable(0,7) &Prefix(VimN0_9)
;;  key L0-_8 = &Variable(0,8) &Prefix(VimN0_9)
;;  key L0-_9 = &Variable(0,9) &Prefix(VimN0_9)
;;
;;  # }}}
;;
#IfWInActive
; }}} Vim mode

; Terminal/Vim {{{
#IfWInActive, ahk_group Terminal
Esc:: ; Just send Esc at converting.
  if (IME_GET(A)) {
    if (IME_GetConverting(A)) {
      Send {Esc}
    } else {
      Send {vkF3sc029}
      Send {Esc} ; Esc should be in separated Send command from vkF3sc029
                 ; Otherwise vkF3sc029 works wrong (write ,.-?)
    }
  } else {
    Send {Esc}
  }
  return


^[:: ; Go to Normal mode (for vim) with IME off even at converting.
  if (IME_GET(A)) {
    Send {Esc}
    Send {vkF3sc029}
    Send {Esc}
  } else {
    Send {Esc}
  }
  return
#IfWInActive

; Other than Terminal/Vim {{{
#IfWInNotActive, ahk_group Terminal
^[::Send {Esc}             ; Always C-[ to ESC, like vim
#IfWInNotActive
; }}}
; }}}

; For powerpoint {{{
#IfWInActive, ahk_class PP12FrameClass
^Space::Send {Right}, +{Left}
^=::Send ^t, b,  {Enter}
^+=::Send ^t, p, {Enter}
; for JP keyboards
;^-::Send ^t, b,  {Enter}
;^+-::Send ^t, p, {Enter}
^+s::Send ^t, fsymbol, {Enter}
^+a::Send ^t, farial, Enter
^+h::Send ^t, fhel v e t i c a Enter
#IfWInActive
; }}}

; For word {{{
#IfWInActive, ahk_class OpusApp
^Space::Send {Right}, +{Left}
^=::Send ^t, b,  {Enter}
^+=::Send ^t, p, {Enter}
; for JP keyboards
;^-::Send ^t, b,  {Enter}
;^+-::Send ^t, p, {Enter}
#IfWInActive
; }}}

; Global Settings {{{
#if
; Basic Settings {{{
; For Alt-Ctrl Swap (swapped by KeySwap)
LCtrl & Tab::AltTab
Alt & Tab::
  if GetKeyState("Shift","P") {
    msgbox, "A-S-Tab"
    ;Send ^+{Tab} ; dosen't work ()
  }else{
    Send ^{Tab}
  }
  Return
;Alt & m::Send ^m
;Ctrl & m::Send !m
Ctrl & Left::Send !{Left}
Ctrl & Right::Send !{Right}

; Other basic settings
!Space::Send {vkF3sc029}   ; IME by A-Space
^Space::Send {vkF3sc029}   ; IME by C-Space
^h::Send {BS}              ; Always BS with C-h
!a::Send ^{Space},n        ; Minimize window
!4::Send !{F4}             ; Close window
^4::Send !{F4}             ; Close window
!d::Send {Del}             ; Always Delete with A-d
;^o::Send !{Left}           ; Go to previous page
;^i::Send !{Right}          ; Go to nexe page
^Space::!`                 ; IME

; For HHK
; ESC to ` like normal keyboard (ESC is placed on the left of 1 in HHK)
!1::!`                ; IME
; }}}

; Cursor, Mouse, Window move/size {{{
; Cursor {{{
!^h::Send {Left}
!^j::Send {Down}
!^k::Send {Up}
!^l::Send {Right}
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
  MouseMove, 10, 10, 0
  MouseClick, Right
  return

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
^o::Send !{Left}
^i::Send !{Right}
#IfWInActive
; }}}

; }}}
