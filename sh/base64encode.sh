#!/bin/sh
set -o nounset -o errexit

test "${guard_dd43fb8+set}" = set && return 0; guard_dd43fb8=x

base64 --output=-
