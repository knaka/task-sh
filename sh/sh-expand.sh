#!/bin/sh
set -o nounset -o errexit

test "${guard_cae4282+set}" = set && return 0; guard_cae4282=x

set -- "test" "-n" ""

if "$@"
then
  echo The test should fail. >&2
  exit 1
fi
