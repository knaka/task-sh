#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_6a33077-false}" && return 0; sourced_6a33077=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./task-go-install-cmd-run.lib.sh
cd "$1"; shift 2

peco() {
  go_install_cmd_run github.com/knaka/peco/cmd/peco@v0.5.13 "$@"
}

case "${0##*/}" in
  (peco.sh|peco)
    set -o nounset -o errexit
    peco "$@"
    ;;
esac
