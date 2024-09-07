#SingleInstance force

; #UseHook - 構文と使用法｜AutoHotkey v2 https://ahkscript.github.io/ja/docs/v2/lib/_UseHook.htm
#UseHook

; キーリスト - AutoHotkey Wiki https://ahkwiki.net/KeyList

^g::Send "{Delete}"
^h::Send "{Backspace}"
^m::Send "{Enter}"
^s::Send "{Left}"
^d::Send "{Right}"
^e::Send "{Up}"
^x::Send "{Down}"
^r::Send "{PgUp}"
^c::Send "{PgDn}"

#z:: Send "^{z}"
#x:: Send "^{x}"
#c:: Send "^{c}"
#v:: Send "^{v}"
#s:: Send "^{s}"
#w:: Send "^{w}"
#t:: Send "^{t}"

<#Space:: Send Chr(0x60)
>#Space:: Send "{Escape}"

; ----------------------------------------

;*LWin::Return
;*LWin Up::Send Chr(0x60)

;LWin::Return
;LWin Up::Send("Hello")
;LWin & c::Send "^{c}"

;LWin Up:: {
;  If (A_PriorKey = "LWin")Hello
;    Send "X"
;  Return
;}

;LWin & F1::Return
;LWin::Send Chr(0x60)
;LWin & F1::Return
;LWin::Send "Y"
;LWin Up::Send "X"
;LWin & c::Send "^{c}"

;<# Up::Send "X"

;RWin::Return
;RWin Up::Send "X"
;RWin & c::Send "^{c}"


;LWin::Send Chr(0x60)
;LWin & c::Send "^c"

;~LWin::SendSuppressedKeyDown "aaa"
; LWin::Send Chr(0x60)
; !Space::Send "{vk1Csc079}"

; !Space::Send "{vk1Csc079}"
; !Space::Send "{vk1Dsc07B}"
