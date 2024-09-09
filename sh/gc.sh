#!/bin/sh
set -o nounset -o errexit

if test "$(uname -s)" = "Windows_NT"
then
  # The sed(1) script is to remove the trailing newline.
  powershell.exe -command "Get-Clipboard" | sed -e ':a; $!N; $ s/\n$//; ta'
else
  xclip -selection clipboard
fi
