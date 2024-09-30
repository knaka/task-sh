#!/bin/sh
set -o nounset -o errexit

test "${guard_180a349+set}" = set && return 0; guard_180a349=-

. task.sh

subcmd_go() ( # Redirect to the go task.
  sh "$SCRIPT_DIR"/../go/task.sh go "$@"
)
