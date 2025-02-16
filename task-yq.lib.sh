#!/bin/sh
test "${guard_be3b5ef+set}" = set && return 0; guard_be3b5ef=-

. ./task.sh

subcmd_yq() { # Run jq(1).
  run_pkg_cmd \
    --cmd=yq \
    --brew-id=yq \
    --winget-id=mikefarah.yq \
    --win-cmd-path="$HOME"/AppData/Local/Microsoft/WinGet/Links/yq.exe \
    -- "$@"
}
