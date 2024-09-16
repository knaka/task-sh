#!/bin/sh
set -o nounset -o errexit

if test "$(uname -s)" = "Windows_NT"
then
  clip.exe
elif type pbcopy > /dev/null 2>&1
then
  pbcopy
elif type xclip > /dev/null 2>&1
then
  xclip -selection clipboard
elif type xsel > /dev/null 2>&1
then
  xsel --clipboard
else
  echo "No clipboard utility found." >&2
  exit 1
fi
