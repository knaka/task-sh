#!/bin/sh
test "${guard_6251d0c+set}" = set && return 0; guard_6251d0c=-
set -o nounset -o errexit

: "${x5424913:=initial value}"

echo sourced x5424913 is "$x5424913"
