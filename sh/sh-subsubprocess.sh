#!/bin/sh
set -o nounset -o errexit

test "${guard_923c1c2+set}" = set && return 0; guard_923c1c2=x

sh -c '

clean() {
  kill %%
}

trap clean EXIT

( while true; do echo hello; sleep 1; done )

' &

sleep 3

while true
do
  jobs
  if test -z "$(jobs)"
  then
    break
  fi
  kill %%
done

