#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_e2216a8-}" = true && return 0; sourced_e2216a8=true
set -o nounset -o errexit

set -- "$PWD" "${0%/*}" "$@"; test "$2" != "$0" && cd "$2"
. ./task.sh
cd "$1"; shift 2

printf '\n\r' | {
  read -r newlines
  printf "%s" "$newlines"
}
