#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_cd48f46-}" = true && return 0; sourced_cd48f46=true
set -o nounset -o errexit

fdirname() {
  printf "%s\n" "${1%/*}"
}

filepath="${ fdirname "$file"; }/file.txt"
echo "$filepath"
