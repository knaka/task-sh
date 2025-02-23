#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_66b0bec-false}" && return 0; sourced_66b0bec=true

# Launch editor and block until it exits.

set -- "$PWD" "${0%/*}" "$@"; test "$2" != "$0" && cd "$2"
. ./ed.sh
cd "$1"; shift 2

edw() {
  ed --block "$@"
}

if test "${0##*/}" = edw.sh
then
  set -o nounset -o errexit
  edw "$@"
fi
