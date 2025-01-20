#!/bin/sh
set -o nounset -o errexit

exec sh "$(dirname "$0")"/task.sh "$@"
