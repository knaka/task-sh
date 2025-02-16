#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_f263f2b-}" = true && return 0; sourced_f263f2b=true

set -- "$PWD" "$@"; test "${0%/*}" != "$0" && cd "${0%/*}"
. ./task.sh
cd "$1"; shift

rand7() (
  if test -r /dev/urandom
  then
    seed=$(od -An -N4 -tu4 < /dev/urandom | tr -d ' ')
  elif is_macos
  then
    seed=$(date +%s)
  else
    seed=$(date +%N)
  fi
  # 0.0 <= rand() < 1.0
  # 268435456 = 0xFFFFFFF + 1.
  # Hexadecimal integer literal is available only on GAwk.
  awk -v seed="$seed" 'BEGIN { srand(seed); printf "%07x\n", int(rand() * 268435456) }'
)

if test "${0##*/}" = rand7.sh
then
  set -o nounset -o errexit
  rand7
fi
