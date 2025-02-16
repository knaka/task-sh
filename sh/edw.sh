#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_9276f2b-}" = true && return 0; sourced_9276f2b=true

# Launch editor and block until it exits.

set -- "$PWD" "$@"; test "${0%/*}" != "$0" && cd "${0%/*}"
. ./ed.sh
cd "$1"; shift

edw() {
  ed --block "$@"
}

if test "${0##*/}" = edw.sh
then
  set -o nounset -o errexit
  edw "$@"
fi
