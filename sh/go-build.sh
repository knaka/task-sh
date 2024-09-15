#!/bin/sh
set -o nounset -o errexit
exec go build -gcflags='all=-N -l' "$@"
