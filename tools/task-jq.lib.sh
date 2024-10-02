#!/bin/sh
set -o nounset -o errexit

test "${guard_d3015b9+set}" = set && return 0; guard_d3015b9=-

. task.sh

subcmd_jq() ( # Run jq(1).
  cmd=jq
  winget_cmd_path="$HOME"/AppData/Local/Microsoft/WinGet/Links/jq.exe
  run_installed \
    --cmd="$cmd" \
    --brew-id=jq \
    --winget-id=jqlang.jq \
    --winget-cmd-path="$winget_cmd_path" \
    -- "$@"
)
