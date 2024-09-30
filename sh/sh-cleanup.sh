#!/bin/sh
set -o nounset -o errexit

test "${guard_97010e4+set}" = set && return 0; guard_97010e4=x

cleanups=

push_cleanup() {
  cleanups="$1 $cleanups"
}

cleanup() {
  for cleanup in $cleanups
  do
    $cleanup
  done
}

trap cleanup EXIT

cleanup_08ab395() {
  echo "cleanup1"
}
push_cleanup cleanup_08ab395

if true
then
  cleanup_9ec7731() {
    echo "cleanup2"
  }
  push_cleanup cleanup_9ec7731
fi

if true
then
  # It's ok to overwrite the cleanup function in subshell.
  (
    cleanup() {
      # shellcheck disable=SC2317
      echo "cleanup3"
    }
    trap cleanup EXIT
    exit 1
  )
fi

echo aea644d

# true
false
# exec /usr/bin/true
