#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_c521fa4-}" = true && return 0; sourced_c521fa4=true
set -o nounset -o errexit

pids=

sleep 1234 &
pids="$pids $!"

sleep 1234 &
pids="$pids $!"

sh ./sh-sleep.sh 2345 &
pids="$pids $!"

sleep 1

# for pid in $pids
# do
#   kill "$pid" || :
#   wait "$pid" || :
#   echo Killed "$pid" >&2
# done

jobs -p

p=/users/knaka/tmp/jobs.txt
jobs | sed -E -e 's/^[^0-9]*([0-9]+).*Running/\1/' >"$p"
while read -r jid
do
  kill "%$jid" || :
  wait "%$jid" || :
  echo Killed "%$jid" >&2
done <"$p"

# jobs | sed -E -e 's/^[^0-9]*([0-9]+).*Running/\1/' | while read -r jid
# do
#   kill "%$jid" || :
#   wait "%$jid" || :
#   echo Killed "%$jid" >&2
# done

# echo pids: $pids

# for jid in $(jobs -p)
# do
#   kill "$jid" || :
#   wait "$jid" || :
#   echo Killed "$jid" >&2
# done
