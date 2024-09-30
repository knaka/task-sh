#!/bin/sh
set -o nounset -o errexit

test "${guard_c816161+set}" = set && return 0; guard_c816161=-

. task.sh 

GO111MODULE=on sh "$SCRIPT_DIR"/cmd-go.sh list -m --json "$@"
