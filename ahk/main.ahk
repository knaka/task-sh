#Requires AutoHotkey v2.0
#SingleInstance force

; How to remove-uninstall Game Bar? - Microsoft Community https://answers.microsoft.com/en-us/xbox/forum/all/how-to-remove-uninstall-game-bar/77cfbfd5-1588-4d0f-b9c6-4c47ed899049
; Get-AppxPackage -PackageTypeFilter Bundle -Name "*Microsoft.XboxGamingOverlay*" | Remove-AppxPackage
<!>!s:: WinActivate("ahk_exe WindowsTerminal.exe")
<!>!b:: WinActivate("ahk_exe chrome.exe")
<!>!e:: WinActivate("ahk_exe Code.exe")

#UseHook

; List of Keys (Keyboard, Mouse and Controller) | AutoHotkey v2 https://www.autohotkey.com/docs/v2/KeyList.htm

; WinActive - Syntax & Usage | AutoHotkey v2 https://www.autohotkey.com/docs/v2/lib/WinActive.htm
; #HotIf - Syntax & Usage | AutoHotkey v2 https://www.autohotkey.com/docs/v2/lib/_HotIf.htm

#HotIf WinActive("ahk_exe WindowsTerminal.exe")
<^p::Send "{Up}"
<^n::Send "{Down}"
#HotIf

#HotIf !WinActive("ahk_exe WindowsTerminal.exe")
<^e::Send "{Up}"
<^x::Send "{Down}"
<^r::Send "{PgUp}"
<^c::Send "{PgDn}"
<^>^f::Send "{End}"
<^>^a::Send "{Home}"

<^+e::Send "+{Up}"
<^+x::Send "+{Down}"
<^+r::Send "+{PgUp}"
<^+c::Send "+{PgDn}"
<^>^+f::Send "+{End}"
<^>^+a::Send "+{Home}"
#HotIf

<^s::Send "{Left}"
<^d::Send "{Right}"
<^a::Send "<^{Left}"
<^f::Send "<^{Right}"

+<^s::Send "+{Left}"
+<^d::Send "+{Right}"
+<^a::Send "+^{Left}"
+<^f::Send "+^{Right}"

<^m::Send "{Enter}"
<^g::Send "{Delete}"
<^h::Send "{Backspace}"

<!a:: Send "^{a}"
<!b:: Send "^{b}"
<!c:: Send "^{c}"
<!d:: Send "^{d}"
<!e:: Send "^{e}"
<!f:: Send "^{f}"
<!g:: Send "^{g}"
<!h:: Send "^{h}"
<!i:: Send "^{i}"
<!j:: Send "^{j}"
<!k:: Send "^{k}"
<!l:: Send "^{l}"
<!m:: Send "^{m}"
<!n:: Send "^{n}"
<!o:: Send "^{o}"
<!p:: Send "^{p}"
<!q:: Send "^{q}"
<!r:: Send "^{r}"
<!s:: Send "^{s}"
<!t:: Send "^{t}"
<!u:: Send "^{u}"
<!v:: Send "^{v}"
<!w:: Send "^{w}"
<!x:: Send "^{x}"
<!y:: Send "^{y}"
<!z:: Send "^{z}"

<!/:: Send "^{/}"
>!<!h:: {
  n := Random(0, 268435455)
  Send Format("{:07x}", n)
}

LAlt & LButton:: Send "^{LButton}"

>^Space:: Send "{Escape}"
<!Space:: Send Chr(0x60)

;Shift Up:: Send Chr(0x60)

; Autohotkey v2.0のIME制御用 関数群 IMEv2.ahk #AutoHotkey - Qiita https://qiita.com/kenichiro_ayaki/items/d55005df2787da725c6f
; k-ayaki/IMEv2.ahk: Autohotkey v2.0 でIMEを制御する関数群 https://github.com/k-ayaki/IMEv2.ahk
#include imev2.ahk
>!Space:: IME_SET(1)
<^Space:: IME_SET(0)

![:: Send "“”{Left}"
!c:: Send '"$()"{Left}{Left}'
!v:: Send '"${{}}{}}"{Left}{Left}'
