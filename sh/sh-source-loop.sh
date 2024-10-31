#!/bin/sh
set -o nounset -o errexit

test "${guard_2ff5cbb+set}" = set && return 0; guard_2ff5cbb=-

echo be6f940 >&2
cd "$(dirname "$0")"
. ./sh-source-loop.sh
echo 9c45947 >&2
