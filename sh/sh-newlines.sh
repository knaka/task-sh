#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_65909f9-}" = true && return 0; sourced_65909f9=true
set -o nounset -o errexit

set -- "$PWD" "${0%/*}" "$@"; test "$2" != "$0" && cd "$2"
cd "$1"; shift 2

readonly newlines="\x0D\x0A"

sh_newlines() {
  # printf "\n\r"
  printf "%s" "$newlines"
}

case "${0##*/}" in
  (sh-newlines|sh-newlines.sh)
    set -o nounset -o errexit
    sh_newlines "$@"
    ;;
esac
