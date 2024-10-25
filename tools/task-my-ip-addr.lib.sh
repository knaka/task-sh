#!/bin/sh
set -o nounset -o errexit

test "${guard_29a20a9+set}" = set && return 0; guard_29a20a9=-

. task.sh
# . task-json2sh.lib.sh

subcmd_my_ip_addr() {
  # shellcheck disable=SC2119
  eval "$(curl"$(exe_ext)" -o - http://ip.jsontest.com/ 2> /dev/null | subcmd_json2sh)"
  # shellcheck disable=SC2154
  echo "My IP Address: $json__ip"
}

# subcmd_* aliases is “eval”ed in main function.
alias subcmd_my-ip-addr='subcmd_my_ip_addr'
