#!/bin/sh
# shellcheck disable=SC3043
test "${guard_926c124+set}" = set && return 0; guard_926c124=x
set -o nounset -o errexit

. ./task-node.lib.sh

: "${astro_project_dir_0135e32:=$PROJECT_DIR}"

set_astro_project_dir() {
  astro_project_dir_0135e32="$1"
}

astro_project_dir() {
  echo "$astro_project_dir_0135e32"
}

subcmd_astro() { # Execute Astro command
  run_node_modules_bin astro astro.js --root "$astro_project_dir_0135e32" "$@"
}

task_astro__build() { # Build Astro application
  subcmd_astro build
}
