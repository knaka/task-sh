#!/bin/sh
# shellcheck disable=SC2317
test "${guard_8538e9a+set}" = set && return 0; guard_8538e9a=x
set -o nounset -o errexit

# shellcheck disable=SC2046
marker_line_no="$(IFS=":"; printf "%s\n" $(grep -n "^# embed_53c8fd5" "$0") | head -n 1)"
tail -n "+$((marker_line_no+1))" "$0"
exit 0

# embed_53c8fd5
foo
bar
baz
