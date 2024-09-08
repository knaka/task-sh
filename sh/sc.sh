#!/bin/sh
set -o nounset -o errexit

if test "$(uname -s)" = "Windows_NT"
then
  clip.exe
fi
