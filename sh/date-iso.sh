#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_8cac2e4-false}" && return 0; sourced_8cac2e4=true

# https://ijmacd.github.io/rfc3339-iso8601/

iso_date_format='%Y-%m-%dT%H:%M:%S%z'

date_iso() {
  # -j: Do not try to set the date
  date -j +"$iso_date_format"
}

case "${0##*/}" in
  (date-iso|date-iso.sh|date-rfc3339|date-rfc3339.sh)
    set -o nounset -o errexit
    date_iso "$@"
    ;;
esac
