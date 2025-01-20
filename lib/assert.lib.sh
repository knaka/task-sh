#!/bin/sh
test "${guard_c23f9ad+set}" = set && return 0; guard_c23f9ad=x

# Assertion functions

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

# assert_match expected actual
assert_match() {
  if ! echo "$2" | grep -E -q "$1"
  then
    printf "Failed: \"%s\" does not match \"%s\"\n" "$2" "$1"
    return 1
  fi
}
