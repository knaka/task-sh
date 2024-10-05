#!/bin/sh
set -o nounset -o errexit

test "${guard_ee0740e+set}" = set && return 0; guard_ee0740e=x

. "$(dirname "$0")"/task.sh

# shellcheck disable=SC2154
set_sync_ignored "$@"
