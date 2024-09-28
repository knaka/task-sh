#!/bin/sh
set -o nounset -o errexit

test "${guard_180a349+set}" = set && return 0; guard_180a349=-

. task.sh

subcmd_go() ( # Redirect to the go task.
  cd "$script_dir_path" || exit 1
  sh ../go/task.sh go "$@"
)
