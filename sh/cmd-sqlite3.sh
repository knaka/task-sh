#!/bin/sh
set -o nounset -o errexit

sh "$(dirname "$0")"/../tools/task sqlite3 "$@"
