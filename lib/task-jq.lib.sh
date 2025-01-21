#!/bin/sh
set -o nounset -o errexit

test "${guard_d3015b9+set}" = set && return 0; guard_d3015b9=-

. ./task.sh

subcmd_jq() { # Run jq(1).
  run_pkg_cmd \
    --cmd=jq \
    --brew-id=jq \
    --winget-id=jqlang.jq \
    --winget-cmd-path="$HOME"/AppData/Local/Microsoft/WinGet/Links/jq.exe \
    -- "$@"
}

subcmd_json2sh() {
  # shellcheck disable=SC2016
  subcmd_jq -r '
def to_sh(prefix):
  to_entries[] |
  .key as $k |
  ($k | gsub("[-\\.]"; "_")) as $keyForShell |
  if (.value | type == "object") then
    .value | to_sh("\(prefix)\($keyForShell)__")
  else
    "\(prefix)\($keyForShell)=\"\(.value)\""
  end;

to_sh("json__")
'
}
