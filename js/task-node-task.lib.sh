#!/bin/sh
set -o nounset -o errexit

set_dir_sync_ignored "$(dirname "$0")"/node_modules

delegate_tasks() (
  ORIGINAL_WD="$PWD"
  export ORIGINAL_WD
  cd "$(dirname "$0")" || exit 1
  subcmd_volta run node ./task.cjs "$@"
)
