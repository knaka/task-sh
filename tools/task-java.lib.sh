#!/bin/sh
set -o nounset -o errexit

test "${guard_43a0925+set}" = set && return 0; guard_43a0925=x

. task.sh

subcmd_java() {
  sh "$SCRIPT_DIR"/../java/task.sh java "$@"
}
