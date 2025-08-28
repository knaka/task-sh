#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_92d8973-false}" && return 0; sourced_92d8973=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./task.sh
cd "$1"; shift 2

iso_time_format='%Y-%m-%dT%H:%M:%S%z'
iso_time_format_utc='%Y-%m-%dT%H:%M:%SZ'

# Touch files with specified ISO time.
# Usage: touch_time_iso <ISO_time> <file>...
# Example: touch_time_iso "2023-12-25T15:30:00Z" file1.txt file2.txt
touch_time_iso() {
  local time="$1"
  shift
  # BSD touch cannot accept ISO format directly with -d
  if is_bsd
  then
    time="$(TZ=UTC date -j -f "$iso_time_format" "$time" +"$iso_time_format_utc")"
  fi
  touch -d "$time" "$@" 
}

case "${0##*/}" in
  (touch-time-iso.sh|touch-time-iso)
    set -o nounset -o errexit
    touch_time_iso "$@"
    ;;
esac
