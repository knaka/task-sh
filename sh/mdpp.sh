#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_1862275-false}" && return 0; sourced_1862275=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./task-mdpp.lib.sh
cd "$1"; shift 2

case "${0##*/}" in
  (mdpp.sh|mdpp)
    set -o nounset -o errexit
    mdpp "$@"
    ;;
esac
