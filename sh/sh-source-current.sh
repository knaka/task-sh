#!/bin/sh
set -o nounset -o errexit

test "${guard_9b27a75+set}" = set && return 0; guard_9b27a75=x

. task.sh
