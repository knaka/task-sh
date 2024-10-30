#!/bin/sh
set -o nounset -o errexit

test "${guard_701e126+set}" = set && return 0; guard_701e126=x

sleep 100 &
pid=$!
echo "pid: $pid"
kill $pid
wait $pid

