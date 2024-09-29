#!/bin/sh
set -o nounset -o errexit

test "${guard_7543647+set}" = set && return 0; guard_7543647=-

for arg in "$@"
do
  if ! echo "$arg" | grep -q '^0x'
  then
    arg="0x$arg"
  fi
  printf "%d\n" "$arg"
done
