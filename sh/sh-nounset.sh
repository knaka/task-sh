#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_6b8dcdf-}" = true && return 0; sourced_6b8dcdf=true
set -o nounset -o errexit

# OK
if test "${1+set}" = set && test "$1" = "hello"
# NG
# if test "${1+set}" = set -a "$1" = "hello"
then
  echo "Hello, world!"
else
  echo "Goodbye, world!"
fi
