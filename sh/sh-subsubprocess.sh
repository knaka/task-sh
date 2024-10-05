#!/bin/sh
set -o nounset -o errexit

test "${guard_923c1c2+set}" = set && return 0; guard_923c1c2=x

. "$(dirname "$0")"/task.sh

sh -c 'while true; do echo "cp1"; sleep 1; done' &
sh -c 'while true; do echo "cp2"; sleep 1; done' &
sh -c 'while true; do echo "cp3"; sleep 1; done' &

sleep 1

# shellcheck disable=SC2046

while true
do
  cmd="$(prompt "Command: ")"
  case "$cmd" in
    *) break;;
  esac
done
kill_children
