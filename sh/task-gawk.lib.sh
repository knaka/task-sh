#!/bin/sh
test "${guard_90a1009+set}" = set && return 0; guard_90a1009=x
set -o nounset -o errexit

. ./task.sh

subcmd_gawk() {
  run_pkg_cmd \
    --cmd=gawk \
    --brew-id=gawk \
    -- "$@"
}
