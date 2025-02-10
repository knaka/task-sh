#!/bin/sh
set -o nounset -o errexit

exec "$SH" "$(dirname "$0")"/task.sh "$@"
