#!/bin/sh
set -o nounset -o errexit

test "${guard_29a20a9+set}" = set && return 0; guard_29a20a9=-

. task.sh

# For subcmd_json2sh
if test -r task-json2sh.lib.sh
then
  # shellcheck disable=SC1091
  . task-json2sh.lib.sh
else
  # shellcheck disable=SC1091
  . task-jq.lib.sh
fi

task_my_ip_addr() {
  # shellcheck disable=SC2119
  eval "$(memoize d9e8d98 curl"$(exe_ext)" -o - http://ip.jsontest.com/ | subcmd_json2sh)"
  # shellcheck disable=SC2154
  echo "My IP Address: $json__ip"
}

# subcmd_* aliases is “eval”ed in main function.
# alias task_my-ip-addr='task_my_ip_addr'

headers() {
  memoize 28e678f cross_run curl -o - http://headers.jsontest.com/
}

task_headers() {
  headers | subcmd_jq -r '.["User-Agent"]'
  headers | subcmd_jq -r '.["Host"]'
}
