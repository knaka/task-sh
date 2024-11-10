#!/bin/sh
test "${guard_9e2d633+set}" = set && return 0; guard_9e2d633=x
set -o nounset -o errexit

unit_sep="$(printf '\x1f')"
usv_items="$(printf 'foo%sbar\nbaz%squx' "$unit_sep" "$unit_sep")"
IFS="$unit_sep"
# shellcheck disable=SC2086
printf "%s\0" $usv_items | xargs -0 -n1 echo "arg:"
unset IFS
