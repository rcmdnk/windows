Windows
=======

This is repository for windows setting files.

## Yet Another Mado tsukai no Yuutsu (yamy)
[yamy](http://sourceforge.jp/projects/yamy/) is keybind customize software
for  windows.
For basic settings, you can refer
[the manual of Mado Tukai no Yuutsu](http://mayu.sourceforge.net/mayu/doc/README-ja.html), which is a base of yamy

My blog about [yamy](http://rcmdnk.github.com/blog/categories/yamy/)
also could help you!

This repository has some files for yamy.

### .mayu
My main setting file.

### .local.mayu
Settings for each PC.
It has settings of window alignment (depends on a display dimension).

### vimedit.mayu
In this file, the settings for vim-like move/edit are extracted from .mayu file.
It can work standalone.

Following features are available.

#### Vim-like cursor move with Alt+Control (or CapsLock)
You can move a cursor with `A-C-[hjkl]` to left, down, up, and right
like vim in anytime. (It just sends eacy cursor key command.)

In addition, if CapslLock is set, `hjkl` can be used standalone to move around.


    * Cursor Move (A-C- can be removed when CapsLock is set)
      * A-C-h: Cursor Left
      * A-C-j: Cursor Down
      * A-C-k: Cursor Up
      * A-C-l: Cursor Right

#### Vim-like mouse move with Alt+Control (or CapsLock)
A mouse cursor also can be moved by a keyboard.

`A-C-y` moves a mouse cursor to the left, and `A-C-`+`u`,`i`,`o`
moves to the up, down and right, respectively.
(`yuio` are on the `hjkl`.)

Capslock can be used in this case, too.
Such `y` moves a mouse cursor to the left when Capslock is set.

In addition, click/mouse wheel also can be used from the keyboard as followings.

    * Mouse Move (When CapsLock is set, A-C- must not used)
      * A-C-y: Mouse Left
      * A-C-u: Mouse Down
      * A-C-i: Mouse Up
      * A-C-o: Mouse Right
    * Mouse Click (A-C- can be removed when CapsLock is set)
      * A-C-n: Mouse Left Click
      * A-C-p: Mouse Right Click
    * Mouse Wheel (A-C- can be removed when CapsLock is set)
      * A-C-m: Mouse Wheel Down
      * A-C-, Mouse Wheel Up
      * A-S-C-m (or CapsLock-S-m): Mouse Wheel More Down
      * A-S-C-, (or CapsLock-S-,):  Mouse Wheel More Up

#### Vim-like Window move Alt+Shift
You can also move windows w/o mosue!

    * Window Move
      * A-S-y: Window Move Left
      * A-S-u: Window Move Down
      * A-S-i: Window Move Up
      * A-S-o: Window Move Right

#### Vim emulation
With `vimedit.mayu`, vim mode is available on Thunderbird, Notepad, and TeraPad.
You can add any other applications in the setting file if you want.

##### Mode
Following modes are available
|Mode|Description|
|:---|:----------|
|Insert Mode|Normal Windows state|
|Normal Mode|As in vim, cursor is moved by hjkl, w, etc... and some vim like commands are available.|
|Visual Mode|There are three visual mode: Character-wise, Line-wise, and Block-wise. Block-wise visual mode is available only the applications which support it (In the default applications, only TeraPad support Block-sise mode.)|

Initial state is `Insert Mode`, then `Esc` or `C-[` bring you to the normal mode.

In the normal mode, `i` is the key to be back to the insert mode.

`v`, `S-v` and `C-v` are the key to the Character-wise, Line-wise, and Block-wise
visual mode, respectively.








