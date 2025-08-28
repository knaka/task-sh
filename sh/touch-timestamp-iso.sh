#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_92d8973-false}" && return 0; sourced_92d8973=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./task.sh
cd "$1"; shift 2

iso_date_format='%Y-%m-%dT%H:%M:%S%z'
iso_date_format_utc='%Y-%m-%dT%H:%M:%SZ'

# Touch files with specified ISO timestamp.
# Usage: touch_timestamp_iso <ISO_timestamp> <file>...
# Example: touch_timestamp_iso "2023-12-25T15:30:00Z" file1.txt file2.txt
touch_timestamp_iso() {
  local date="$1"
  shift
  # Linux touch accepts ISO format directly with -d
  if is_bsd
  then
    date="$(TZ=UTC date -j -f "$iso_date_format" "$date" +"$iso_date_format_utc")"
  fi
  touch -d "$date" "$@" 
}

case "${0##*/}" in
  (touch-timestamp-iso.sh|touch-timestamp-iso)
    set -o nounset -o errexit
    touch_timestamp_iso "$@"
    ;;
esac
