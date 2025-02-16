#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_25dcfe6-}" = true && return 0; sourced_25dcfe6=true

dec_to_hex() {
  local arg
  for arg in "$@"
  do
    printf "0x%X\n" "$arg"
  done
}

if test "${0##*/}" = "10to16.sh"
then
  set -o nounset -o errexit
  dec_to_hex "$@"
fi
