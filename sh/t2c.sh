#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_2856f07-false}" && return 0; sourced_2856f07=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./task-mlr.lib.sh
cd "$1"; shift 2

t2c() {
  mlr --pass-comments --t2c cat "$@"
}

case "${0##*/}" in
  (t2c.sh|t2c)
    set -o nounset -o errexit
    t2c "$@"
    ;;
esac
