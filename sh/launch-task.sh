#!/bin/sh
set -o nounset -o errexit

test "${guard_c6d16e2+set}" = set && return 0; guard_c6d16e2=x

if type ./task >/dev/null 2>&1
then
  exec ./task "$@"
fi
