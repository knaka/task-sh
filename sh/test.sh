#!/bin/sh
set -o nounset -o errexit

test "${guard_7c61789+set}" = set && return 0; guard_7c61789=x

. ./task.sh

test_no_02a08f0=1
some_failed_fa5b802=false

setup_test() {
  :
}

teardown_test() {
  if $some_failed_fa5b802
  then
    echo "Some tests failed"
    exit 1
  fi
}

if test -t 1
then
  RED=$(printf "\e[31m")
  GREEN=$(printf "\e[32m")
  MAGENTA=$(printf "\e[35m")
  NORMAL=$(printf "\e[00m")
  BOLD=$(printf "\e[01m")
else
  RED=""
  GREEN=""
  MAGENTA=""
  NORMAL=""
  BOLD=""
fi

assert_eq() {
  test_name="${3:-}"
  if test -z "$test_name"
  then
    test_name="Test-$test_no_02a08f0"
  fi
  if test "$1" = "$2"
  then
    echo "$GREEN\"$test_name\" Passed$NORMAL"
  else
    echo "$RED\"$test_name\" Failed$NORMAL: \"$1\" != \"$2\""
    some_failed_fa5b802=true
  fi
  test_no_02a08f0=$((test_no_02a08f0+1))
}

setup_test

assert_eq "Foo Bar" "$(menu_item "Foo Bar")"
assert_eq "Hoge" "Fuga" "Different strings"

teardown_test
