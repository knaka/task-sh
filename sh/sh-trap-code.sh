#!/bin/sh
set -o nounset -o errexit

test "${guard_7949921+set}" = set && return 0; guard_7949921=x

# shellcheck disable=SC2317
on_exit() {
  rc=$?
  echo "Exiting with status $?" >&2
  if test "$rc" -ne 0
  then
    echo "Error occurred in line $1" >&2
  fi
}

# shellcheck disable=SC2317
on_error() {
  echo "Error occurred in line $1" >&2
}

trap on_exit EXIT
# In POSIX sh, trapping ERR is undefined.
# trap on_error ERR

echo "Hello, world!" >&2
# exit 0
exit 2
