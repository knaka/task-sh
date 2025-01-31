#!/bin/sh
test "${guard_9cb8c41+set}" = set && return 0; guard_9cb8c41=x
set -o nounset -o errexit

. ./task-node.lib.sh

test_my_ip_addr() {
  "$SH" task.sh my_ip_addr
}

subcmd_js_yaml() {
  run_node_modules_bin js-yaml bin/js-yaml.js "$@"
}

test_npx_in_subdir() {
  cd ./subdir/
  subcmd_node --help
  subcmd_js_yaml --help
  cd ..
}
