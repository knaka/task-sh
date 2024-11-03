#!/bin/sh
set -o nounset -o errexit

test "${guard_c23f9ad+set}" = set && return 0; guard_c23f9ad=x

assert_eq() {
  if ! test "$1" = "$2"
  then
    printf "Failed: %s != %s\n" "$1" "$2"
    return 1
  fi
}

assert_neq() {
  if test "$1" = "$2"
  then
    printf "Failed: %s == %s\n" "$1" "$2"
    return 1
  fi
}

assert_true() {
  if ! "$@"
  then
    printf "Failed: \"%s\" is not true\n" "$*"
    return 1
  fi
}

assert_false() {
  if "$@"
  then
    printf "Failed: \"%s\" is not false\n" "$*"
    return 1
  fi
}
