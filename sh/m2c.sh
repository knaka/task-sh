#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_7f5d0a8-false}" && return 0; sourced_7f5d0a8=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./task-miller.lib.sh
cd "$1"; shift 2

m2c() {
  mlr --pass-comments --m2c cat "$@"
}

case "${0##*/}" in
  (m2c.sh|m2c)
    set -o nounset -o errexit
    m2c "$@"
    ;;
esac
