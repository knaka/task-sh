#!/bin/sh
set -o nounset -o errexit

test "${guard_7975dd8+set}" = set && return 0; guard_7975dd8=x

exec sh "$(dirname "$0")"/../rs/task.sh cargo_in_original "$@"
