#!/bin/sh
test "${guard_3b02cef+set}" = set && return 0; guard_3b02cef=-
set -o nounset -o errexit

x5424913="my value" . ./sh-sourced.lib.sh

echo sourcing: x5424913 is "$x5424913"
