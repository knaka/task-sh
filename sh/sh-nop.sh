#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_f0985a8-false}" && return 0; sourced_f0985a8=true

set -- "$PWD" "${0%/*}" "$@"; test "$2" != "$0" && cd "$2"
. ./task.sh
cd "$1"; shift 2

echo NOP
