#!/bin/sh
set -o nounset -o errexit

test "${guard_2040902+set}" = set && return 0; guard_2040902=x

. task.sh

set_dir_sync_ignored "$SCRIPT_DIR"/node_modules

delegate_tasks() (
  chdir_script
  subcmd_volta run node ./task.cjs "$@"
)
