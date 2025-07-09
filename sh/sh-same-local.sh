#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_64114f4-false}" && return 0; sourced_64114f4=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
cd "$1"; shift 2

sh_same_local() {
  local foo="bar"
  echo "$foo"
  local foo="baz"
  echo "$foo"
}

case "${0##*/}" in
  (sh-same-local.sh|sh-same-local)
    set -o nounset -o errexit
    sh_same_local "$@"
    ;;
esac
