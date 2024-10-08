#!/bin/sh
set -o nounset -o errexit

foo() { while true; do echo foo; sleep 1; done }
foo &
sleep 3
kill %+
exit 0

# bar() ( while true; do echo bar; sleep 1; done )
# bar &
# sleep 3
# kill %+
# exit 0

task_hello1() {
  while true
  do
    echo hello1 $$, $PPID
    sleep 1
  done
}

task_hello2()
(
  while true
  do
    echo hello2 $$, $PPID
    sleep 1
  done
)

# task_hello2 does not get killed.

task_hello1 &
# task_hello2 &
sh -c '
task_hello2() (
  while true
  do
    echo hello2 $$, $PPID
    sleep 1
  done
)
task_hello2
' &
(
  while true
  do
    echo hello3 $$, $PPID
    sleep 1
  done
) &
sleep 3

# while true
# do
#   i_519fa93=$(jobs | sed -nE -e 's/^\[([0-9]+)\]\+.*/\1/p')
#   if test -z "$i_519fa93"
#   then
#     break
#   fi
#   kill "%$i_519fa93"
#   wait "%$i_519fa93" > /dev/null 2>&1 || :
#   jobs
# done

for pid_7e44bc0 in $(jobs -p | tail -r)
do
  kill "$pid_7e44bc0"
  wait "$pid_7e44bc0" > /dev/null 2>&1 || :
done
