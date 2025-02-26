#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_7326780-false}" && return 0; sourced_7326780=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./platform.lib.sh
cd "$1"; shift 2

# Generates a random 7-digit hexadecimal number
rand7() (
  local seed
  if test -r /dev/urandom
  then
    # Generate seed from /dev/urandom if available
    seed=$(od -An -N4 -tu4 </dev/urandom | tr -d ' ')
  elif is_macos
  then
    # Generate seed from current timestamp on macOS in second precision
    seed=$(date +%s)
  else
    # Generate seed from nanoseconds since epoch on other platforms
    seed=$(date +%N)
  fi
  # 0.0 <= rand() < 1.0
  # 268435456 = 0xFFFFFFF + 1
  # Hexadecimal integer literal is available only on GAwk.
  awk -v seed="$seed" 'BEGIN { srand(seed); printf "%07x\n", int(rand() * 268435456) }'
)

if test "${0##*/}" = rand7.sh
then
  set -o nounset -o errexit
  rand7
fi
