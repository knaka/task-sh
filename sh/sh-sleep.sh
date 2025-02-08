#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_a206950-}" = true && return 0; sourced_a206950=true
set -o nounset -o errexit

exec sleep.exe "$@"

echo hoge
sleep 1000

# pids=

# cleanup() {
#   for pid in $pids
#   do
#     kill "$pid" || :
#     wait "$pid" || :
#     echo Killed "$pid" >&2
#   done
# }

# trap cleanup EXIT

# sleep.exe "$@" &
# pids="$pids $!"

# while true
# do
#   sleep 1000
# done
