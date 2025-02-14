#!/bin/sh
set -o nounset -o errexit

test "${guard_2040902+set}" = set && return 0; guard_2040902=x

. ./task.sh
. ./task-volta.lib.sh

delegate_tasks() (
  subcmd_volta run node ./task.cjs "$@"
)
