#!/bin/sh
set -o nounset -o errexit
export LC_ALL=C

test "${guard_7949921+set}" = set && return 0; guard_7949921=x

# shellcheck disable=SC2317
on_exit() {
  rc=$?
  echo "Exiting with status $rc" >&2
  # if test "$rc" -ne 0
  # then
  #   echo "Error occurred in line $1" >&2
  # fi
  exit "$rc"
}

# shellcheck disable=SC2317
on_error() {
  echo "Error occurred in line $1" >&2
}

trap on_exit EXIT
# In POSIX sh, trapping ERR is undefined.
# trap on_error ERR

"$3"

echo "Hello, world!" >&2
# exit 0
exit 2
