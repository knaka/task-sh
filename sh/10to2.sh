#!/bin/sh
set -o nounset -o errexit

test "${guard_665c14c+set}" = set && return 0; guard_665c14c=x

dec_to_bin() {
  num=$1
  bin=
  while test "$num" -gt 0
  do
    bin=$((num % 2))$bin
    num=$((num / 2))
  done
  echo "${bin:-0}"
}

dec_to_bin "$@"
