#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_20bf1eb-false}" && return 0; sourced_20bf1eb=true

set -- "$PWD" "${0%/*}" "$@"; test "$2" != "$0" && cd "$2"
. ./task.sh
cd "$1"; shift 2

alice() {
  echo "Alice is called."
}

bob() {
  echo "Bob is called."
}

my_menu() {
  menu \
    "&Alice" \
    "&Bob" \
    # nop
  case "$(get_key)"
  in
    (a) alice;;
    (b) bob;;
  esac
}

case "${0##*/}" in
  (sh-menu|sh-menu.sh)
    set -o nounset -o errexit
    my_menu "$@"
    ;;
esac
