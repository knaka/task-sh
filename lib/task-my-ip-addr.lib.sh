#!/bin/sh
test "${guard_29a20a9+set}" = set && return 0; guard_29a20a9=-

. ./task.sh
. ./task-json2sh.lib.sh
. ./task-curl.lib.sh

task_my_ip_addr() { # Shows my IP address for testing.
  local cache_file_path
  cache_file_path="$(get_temp_dir_path)"/9fa603e
  if subcmd_curl --fail --output "$cache_file_path" http://api.myip.com/
  then
    # shellcheck disable=SC2119
    eval "$(subcmd_json2sh <"$cache_file_path")"
    # shellcheck disable=SC2154
    echo "My IP Address: $json__ip"
    exit 0
  fi
  echo "Failed to get my IP address." >&2
  exit 1
}
