#!/bin/sh
set -o nounset -o errexit

test "${guard_a24f1b4+set}" = set && return 0; guard_a24f1b4=x

task_build() (
  chdir_script
  if ! newer src/ --than target/
  then
    return 0
  fi
  subcmd_cargo build
)

subcmd_run() {
  "$SCRIPT_DIR"/target/debug/rsmain "$@"
}
