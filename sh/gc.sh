#!/bin/sh
set -o nounset -o errexit

if test "$(uname -s)" = "Windows_NT"
then
  # The sed(1) script is to remove the trailing newline.
  powershell.exe -command "Get-Clipboard" | sed -e ':a; $!N; $ s/\n$//; ta'
elif type pbpaste > /dev/null 2>&1
then
  pbpaste
elif type xclip > /dev/null 2>&1
then
  xclip -selection clipboard -o
elif type xsel > /dev/null 2>&1
then
  xsel --clipboard --output
else
  echo "No clipboard utility found." >&2
  exit 1
fi
