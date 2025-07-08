#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_144cc64-false}" && return 0; sourced_144cc64=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./task-miller.lib.sh
cd "$1"; shift 2

m2t() {
  mlr --pass-comments --m2t cat "$@"
}

case "${0##*/}" in
  (m2t.sh|m2t)
    set -o nounset -o errexit
    m2t "$@"
    ;;
esac
