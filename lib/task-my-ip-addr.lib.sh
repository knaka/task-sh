#!/bin/sh
set -o nounset -o errexit

test "${guard_29a20a9+set}" = set && return 0; guard_29a20a9=-

. ./task.sh

# For `subcmd_json2sh`
# shellcheck disable=SC1091
. ./task-json2sh.lib.sh 2>/dev/null || {
  echo "Falling back to task-jq.lib.sh" >&2
  . ./task-jq.lib.sh
}

task_my_ip_addr() { # Shows my IP address for testing.
  # shellcheck disable=SC2119
  eval "$(memoize d9e8d98 curl"$(exe_ext)" -o - https://api.myip.com/ | subcmd_json2sh)"
  # shellcheck disable=SC2154
  echo "My IP Address: $json__ip"
}
