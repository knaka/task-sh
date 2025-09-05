# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_342d010-false}" && return 0; sourced_342d010=true

. ./task.sh
. ./json2sh.lib.sh

# Shows my IP address for testing.
task_my_ip_addr() {
  local cache_file_path
  cache_file_path="$TEMP_DIR"/9fa603e
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
