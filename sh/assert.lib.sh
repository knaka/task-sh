#!/bin/sh
set -o nounset -o errexit

test "${guard_c23f9ad+set}" = set && return 0; guard_c23f9ad=x

test_no_02a08f0=1

assert_eq() {
  test_name_5dc9aff="Assertion $test_no_02a08f0"
  if test "${3+set}" = set
  then
    test_name_5dc9aff="$3"
  fi
  if ! test "$1" = "$2"
  then
    printf "%s Failed: %s != %s\n" "$test_name_5dc9aff" "$1" "$2"
    return 1
  fi
}
