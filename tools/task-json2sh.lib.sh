#!/bin/sh
set -o nounset -o errexit

test "${guard_2586f1b+set}" = set && return 0; guard_2586f1b=-

. task.sh
. task-jq.lib.sh

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
