#!/bin/sh
set -o nounset -o errexit

test "${guard_8bed917+set}" = set && return 0; guard_8bed917=x

foo() {
  x=123
}

foo
# foo | cat -n
# echo hoge | foo

echo $x
