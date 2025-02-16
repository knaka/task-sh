#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_251a1db-}" = true && return 0; sourced_251a1db=true

sc() {
  if command -v clip.exe >/dev/null 2>&1 # Windows
  then
    clip.exe
  elif command -v pbcopy >/dev/null 2>&1 # macOS
  then
    pbcopy
  elif command -v xclip >/dev/null 2>&1 # Linux
  then
    xclip -selection clipboard
  elif command -v xsel >/dev/null 2>&1 # Linux
  then
    xsel --clipboard
  else
    echo "No clipboard utility found." >&2
    exit 1
  fi
}

case "${0##*/}" in
  (sc|sc.sh)
    set -o nounset -o errexit
    sc "$@"
    ;;
esac
