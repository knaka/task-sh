# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_342d010-false}" && return 0; sourced_342d010=true

. ./task.sh
. ./json2sh.lib.sh

my_ip_addr() {
  local url="https://httpbin.org/ip"
  # local url="http://api.myip.com/"
  eval "$(curl --silent --fail --output - "$url" | json2sh --local --prefix="result__")"
  # shellcheck disable=SC2154
  echo "My IP Address is $result__origin."
}

# Shows my IP address.
task_my_ip_addr() {
  my_ip_addr
}
