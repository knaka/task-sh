#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_8cac2e4-false}" && return 0; sourced_8cac2e4=true

datetime_rfc() {
  LANG=C date "$@" '+%Y-%m-%dT%H:%M:%z'
}

date_rfc3339() {
  datetime_rfc "$@"
}

case "${0##*/}" in
  (datetime-rfc|datetime-rfc.sh|date-rfc3339|date-rfc3339.sh)
    set -o nounset -o errexit
    datetime_rfc "$@"
    ;;
esac
