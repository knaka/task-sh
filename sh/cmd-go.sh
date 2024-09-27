#!/bin/sh
set -o nounset -o errexit

exec "$(dirname "$0")"/../go/task go "$@"
