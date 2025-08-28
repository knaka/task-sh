#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_bd334b5-false}" && return 0; sourced_bd334b5=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./task.sh
cd "$1"; shift 2

iso_date_format='%Y-%m-%dT%H:%M:%S%z'

# Print file timestamp in ISO format.
timestamp_iso() {
  if is_bsd
  then
    # S: String
    # a, m, c, B: Last accessed or modified, or when the inode was last changed, or the birth time of the inode
    stat -f "%Sm" -t "$iso_date_format" "$1"
  else
    date --date "$(stat --format "%y" "$1")" +"$iso_date_format"
  fi
}

case "${0##*/}" in
  (timestamp-iso.sh|timestamp-iso)
    set -o nounset -o errexit
    timestamp_iso "$@"
    ;;
esac
