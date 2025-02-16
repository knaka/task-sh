#!/bin/sh
set -o nounset -o errexit

test "${guard_f39d684+set}" = set && return 0; guard_f39d684=x

. "$(dirname "$0")"/../task.sh

bin_to_dec() (
  dec=0
  for digit in $(echo "$1" | fold -w1 | tac)
  do
    dec=$((dec * 2 + digit))
  done
  echo "$dec"
)

bin_to_dec "$@"
