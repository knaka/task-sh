#!/bin/sh
set -o nounset -o errexit

exec ls -l "$@"
