#!/bin/sh
test "${guard_ea129a3+set}" = set && return 0; guard_ea129a3=x
set -o nounset -o errexit

. ./task.sh

task_gen_shell_embedded() {
  file=go-embedded
  dl_url="https://example.com/foo/bar"
  # body_start="$(grep )"
  # shellcheck disable=SC2046
  line_no_start_marker="$(IFS=:; printf "%s\n" $(grep -E -n "^.+EMBED_FAA58B3" "$file") | head -n 1)"
  head -n "$line_no_start_marker" < "$file" | sed -E -e "s@https://raw.githubusercontent.com/.*@${dl_url}@"
  echo ----------------------------------------------------------------------------
  # shellcheck disable=SC2046
  line_no_end_marker="$(IFS=:; printf "%s\n" $(grep -E -n "^EMBED_FAA58B3" "$file") | head -n 1)"
  tail -n +"$line_no_end_marker" < "$file"
}
