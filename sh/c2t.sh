#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_7f3a869-false}" && return 0; sourced_7f3a869=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./task-mlr.lib.sh
cd "$1"; shift 2

c2t() {
  mlr --pass-comments --c2t cat "$@"
}

case "${0##*/}" in
  (c2t.sh|c2t)
    set -o nounset -o errexit
    c2t "$@"
    ;;
esac
