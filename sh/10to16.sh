#!/bin/sh
set -o nounset -o errexit

test "${guard_6b99114+set}" = set && return 0; guard_6b99114=-

for arg in "$@"
do
  printf "0x%X\n" "$arg"
done
