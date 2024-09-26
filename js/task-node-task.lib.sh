#!/bin/sh
set -o nounset -o errexit

set_dir_sync_ignored "$(dirname "$0")"/node_modules

delegate_tasks() (
  ORIGINAL_PWD="$PWD"
  export ORIGINAL_PWD
  cd "$(dirname "$0")" || exit 1
  subcmd_volta run node ./task.cjs "$@"
)
