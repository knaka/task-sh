#!/bin/sh
set -o nounset -o errexit

test "${guard_5ed9b98+set}" = set && return 0; guard_5ed9b98=x

. task.sh
