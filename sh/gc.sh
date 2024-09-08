#!/bin/sh
set -o nounset -o errexit

if test "$(uname -s)" = "Windows_NT"
then
  powershell.exe -command "Get-Clipboard" | sed -e '$ d'
else
  xclip -selection clipboard
fi
