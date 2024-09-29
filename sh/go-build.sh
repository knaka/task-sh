#!/bin/sh
set -o nounset -o errexit

exec sh "$(dirname "$0")"/../go/task.sh go build -gcflags='all=-N -l' "$@"
