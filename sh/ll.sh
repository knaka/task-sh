#!/bin/sh
set -o nounset -o errexit

test "${guard_36b21b4+set}" = set && return 0; guard_36b21b4=x

. "$(dirname "$0")"/task.sh

BB_GLOBBING=1
export BB_GLOBBING
ls"$(exe_ext)" -l "$@"
