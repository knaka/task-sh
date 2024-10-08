#!/bin/sh
set -o nounset -o errexit

test "${guard_7982db1+set}" = set && return 0; guard_7982db1=x

trap 'echo "Foo"' EXIT

(
  trap 'echo "Bar"' EXIT
)
