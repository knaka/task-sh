#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_c48b48e-false}" && return 0; sourced_c48b48e=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./task.sh
. ./task-node.lib.sh
cd "$1"; shift 2

clipper() {
  # volta run --node 22 npm exec --yes --offline -- @philschmid/clipper@0.2.0 "$@"
  set_node_env
  subcmd_npm__install
  invoke clipper "$@"
}

case "${0##*/}" in
  (clipper.sh|clipper)
    set -o nounset -o errexit
    clipper "$@"
    ;;
esac
