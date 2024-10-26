#!/bin/sh
set -o nounset -o errexit

test "${guard_2b360f3+set}" = set && return 0; guard_2b360f3=x

. task.sh

subcmd_ssh() {
  ssh"$(exe_ext)" "$@"
}
