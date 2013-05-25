Windows
=======

This is repository for windows setting files.

## Yet Another Mado tsukai no Yuutsu (yamy)
[yamy](http://sourceforge.jp/projects/yamy/) is keybind customize software
for  windows.
For basic settings, you can refer
[the manual of Mado Tukai no Yuutsu](http://mayu.sourceforge.net/mayu/doc/README-ja.html), which is a base of yamy

My blog about [yamy](http://rcmdnk.github.com/blog/categories/yamy/) (Japanese only)
also could help you!

This repository has some files for yamy.

### [.mayu](./.mayu)
My main setting file.

### [.local.mayu](./.local.mayu)
Settings for each PC.
It has settings of window alignment (depends on a display dimension).

### [vimedit.mayu](./vimedit.mayu)
In this file, the settings for vim-like move/edit are extracted from .mayu file.
It can work standalone.
[This page](http://rcmdnk.github.com/blog/2013/03/16/yamy4/) also explains this setting.

Following features are available.

#### Vim-like cursor move with Alt+Control (or CapsLock)
You can move a cursor with `Alt-Ctrl-`+`h`,`j`,`k`,`l` to left, down, up, and right
like vim in anytime. (It just sends eacy cursor key command.)

In addition, if `CapslLock` is set, `h`,`j`,`k`,`l` can be used standalone to move around.

    * Cursor Move (`A-C-` can be removed when `CapsLock` is set)
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

    * Mouse Move (When `CapsLock` is set, `A-C-` must not be used)
      * A-C-y: Mouse Left
      * A-C-u: Mouse Down
      * A-C-i: Mouse Up
      * A-C-o: Mouse Right
    * Mouse Click (`A-C-` can be removed when `CapsLock` is set)
      * A-C-n: Mouse Left Click
      * A-C-p: Mouse Right Click
    * Mouse Wheel (`A-C-` can be removed when `CapsLock` is set)
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
With [vimedit.mayu](./vimedit.mayu), vim mode is available on Thunderbird, Notepad, and TeraPad.
You can add any other applications in the setting file if you want ([Ref](http://rcmdnk.github.com/blog/2013/03/16/yamy4/)).

##### Mode
Following modes are available

|Mode|Description|
|:---|:----------|
|Insert Mode|Normal Windows state|
|Normal Mode|As in vim, cursor is moved by hjkl, w, etc... and some vim like commands are available.|
|Visual Mode|There are three visual mode: Character-wise, Line-wise, and Block-wise. Block-wise visual mode is available only the applications which support it (In the default applications, only TeraPad support Block-sise mode.)|
|Command Line Mode|Can be used for saving file/exiting.|
|Search Window| This is not a mode, but to search the word, searching window will be used especially for the first time. Some specific commands are available in the searching window.|

Initial state is `Insert Mode`, then `Esc` or `C-[` bring you to the normal mode.

In the normal mode, `i` is the key to be back to the insert mode.

`v`, `S-v` and `C-v` are the key to the Character-wise, Line-wise, and Block-wise
visual mode, respectively.

After push `:`, a few commands to save/quit are available.
(No command visualizations are there, just put commands after pushing `:`.)

#### Available commands at Normal mode

|Key/Commands|Function|
|:----------:|:-------|
|i/I/a/A/o/O| Enter the insert mode at under the cursor/start of the line/next to the cursor/end of the line/next line/previous line|
|v/S-v/C-v|Enter the visual mode of Character-wise/Line-wise/Block-wise. In the application which doesn't support Block-wise select, it just does Character-wise select.|
|:|Enter the command line mode|
|h/j/k/l|Left/Down/Up/Right|
|0/$| To the first/end character of the line|
|C-a/C-e| To the first/end character of the line (emacs like)|
|w/W/e/E| Move a word forard. All work same. (like `w` in vim)|
|b/B| Move a word backword. All work same. (like `ge` in vim)|
|C-u/C-d| Move Up/Down 10 line|
|C-b/C-f| Move Up/Down 20 line|
|gg/G| Go to the top/end of the file|
|yy, Y| Copy line|
|y0, y$| Copy from here to the first/end of the line|
|yw, yW, ye, yE| Copy following one word|
|yb, yB| Copy previous one word|
|yG, ygg| Copy from here to the top/end of the file|
|yj, yk| Copy blow/above line|
|dd| Cut line|
|d0, d$, D| Cut from here to the first/end of the line (d$=D)|
|dw, dW, de, dE| Cut following one word|
|db, dB| Cut previous one word|
|dG, dgg| Cut from here to the top/end of the file|
|dj, dk| Cut blow/above line|
|c0, c$, C| Cut from here to the first/end of the line (c$=C) and enter in the insert mode|
|cw, cW, ce, cE| Cut following one word and enter in the insert mode|
|cb, cB| Cut previous one word and enter in the insert mode|
|cG, cgg| Cut from here to the top/end of the file and enter in the insert mode|
|cj, ck| Cut blow/above line and enter in the insert mode|
|x/X|Delete a character under/before the cursor (not registered in the clipboard)|
|p/P| Paste to the next/current place. If copy/cut was done with line-wise, 
it pastes to the next/previous line. Some commands (such yy/dd)
also force to paste as line-wise even if it was copied/cut in Character-wise mode.|
|u/C-r| Undo/Redo. Note, some applications support only one time undo and second undo works as redo (`C-r` can't work in that case).|
|J| Combine two lines|
|/| Start search (search box will be opened)|
|n/N| Search next/previous (Some applications support only next search)|
|.| It is fixed to do: `Delete forward word, paste` (useful to use with a search)|
|~| Make a character under the cursor Up case (only to Up, not a toggle)|

In addition, `Repeat` is also available for some commands.
1-99 can be used as a repeat number.

|Example Commands|Action|
|:----------:|:-------|
|4j| Down 4 lines|
|35w| Move 35 words forward|
|4dj| Delete current + 4 lines below|


#### Available commands at Visual mode
|Key/Commands|Function|
|:----------:|:-------|
|Move command| Most of move commands in the normal mode are available|
|y/d/x/c| Copy/Cut/Cut/Cut and insert (`d`=`x`)|
|Y/D/X/C| Move to the end of line, then Copy/Cut/Cut/Cut and insert (`D`=`X`)|

#### Available commands at Command mode
|Key/Commands|Function|
|:----------:|:-------|
|w + Space| Open a save dialog |
|w + Enter| Save |
|w + q| Save and Quit |
|q | Quit |
|h | Open help |

#### Search window
When `/` is pushed, the search window will be opened.
The mode will be changed as the insert mode.
Some special commands are available in the insert/normal modes with the search window.
These commands' availability is depend on a application.

Commands in the insert mode

|Key/Commands|Function|
|:----------:|:-------|
|Enter| Close the window and back to the main window (the searched word is highlighted, and you can continue to search with `n`/`N`)|

Commands in the nomal mode

|Key/Commands|Function|
|:----------:|:-------|
|n/N| Search next/previous with the search window|
|i| Start to change the search word |
|Enter| Enter normal mode, close the window and back to the main window (the searched word is highlighted, and you can continue to search with `n`/`N`)|


#### Demonstration of Vim emulation with yamy, on TeraPad
<p><img src="https://dl.dropbox.com/u/630732/Blog/WinApp/YamyVimEmulation.gif" ></p>

