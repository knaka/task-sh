#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_4dca522-}" = true && return 0; sourced_4dca522=true
set -o nounset -o errexit

temp_dir_path="$(mktemp -d)"
fifo_path="$temp_dir_path/fifo"
mkfifo "$fifo_path"

cleanup() {
  rm -fr "$temp_dir_path"
}
trap cleanup EXIT

(
  for i in 1 2 3
  do
    sleep 0.1
    printf "hello%d" "$i"
  done
) >"$fifo_path" 2>&1 &

output_path="$temp_dir_path/output"
cat "$fifo_path" >"$output_path"

test "$(cat "$output_path")" = "hello1hello2hello3"
