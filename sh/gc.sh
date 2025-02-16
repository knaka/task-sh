#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_432c660-}" = true && return 0; sourced_432c660=true
set -o nounset -o errexit

if test -d "c:/" # Windows
then
  # The sed(1) script is to remove the trailing newline.
  powershell.exe -command "Get-Clipboard" | sed -e ':a; $!N; $ s/\n$//; ta'
elif command -v pbpaste > /dev/null 2>&1 # macOS
then
  pbpaste
elif command -v xclip > /dev/null 2>&1 # Linux
then
  xclip -selection clipboard -o
elif command -v xsel > /dev/null 2>&1 # Linux
then
  xsel --clipboard --output
else
  echo "No clipboard utility found." >&2
  exit 1
fi
