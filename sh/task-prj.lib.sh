#!/bin/sh
test "${guard_0ac87ac+set}" = set && return 0; guard_0ac87ac=x
set -o nounset -o errexit

. ./task.sh
. ./task-gsed.lib.sh
. ./task-gawk.lib.sh

task_foo() {
  echo "foo toupper(bar) baz toupper(qux)" | subcmd_gawk '{ while (match($0, /toupper\(([[:alpha:]]+)\)/, arr)) { $0 = substr($0, 1, RSTART - 1) toupper(arr[1]) substr($0, RSTART + RLENGTH) }; print; }'
}

task_bar() {
  echo "foo toupper(bar) baz toupper(qux)" | subcmd_gsed -E -e 's/\btoupper\(([[:alpha:]]+)\)/\U\1/g'
}
