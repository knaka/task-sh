#!/bin/sh
set -o nounset -o errexit

test "${guard_d3015b9+set}" = set && return 0; guard_d3015b9=-

. task.sh

subcmd_jq() ( # Run jq(1).
  run_installed \
    --name=jq \
    --winget-id=stedolan.jq \
    --winget-path="$HOME"/AppData/Local/Microsoft/WinGet/Links/jq.exe \
    -- "$@"
)
