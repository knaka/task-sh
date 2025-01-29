#!/bin/sh
test "${guard_487b60f+set}" = set && return 0; guard_487b60f=-
set -o nounset -o errexit

foo() {
  echo $?
  echo "foo"
}

trap 'foo' EXIT

# hoge
a=$1
