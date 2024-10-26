#!/bin/sh
set -o nounset -o errexit

test "${guard_2cca18d+set}" = set && return 0; guard_2cca18d=x

base64 --decode --input=-
