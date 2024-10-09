#!/bin/sh
set -o nounset -o errexit

test "${guard_adb683d+set}" = set && return 0; guard_adb683d=x

date_rfc3339() {
  LANG=C date "$@" '+%Y-%m-%dT%H:%M:%z'
}

if test "$(basename "$0")" = "date-rfc3339.sh"
then
  date_rfc3339 "$@"
fi
