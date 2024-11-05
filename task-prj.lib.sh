#!/bin/sh
set -o nounset -o errexit

test "${guard_a8ac234+set}" = set && return 0; guard_a8ac234=x

. ./task.sh
