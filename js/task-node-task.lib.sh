#!/bin/sh
set -o nounset -o errexit

test "${guard_2040902+set}" = set && return 0; guard_2040902=-

. task.sh

set_dir_sync_ignored "$script_dir_path"/node_modules

delegate_tasks() (
  ORIGINAL_WD="$PWD"
  export ORIGINAL_WD
  cd "$script_dir_path" || exit 1
  subcmd_volta run node ./task.cjs "$@"
)
