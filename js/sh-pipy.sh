#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_bd70656-}" = true && return 0; sourced_bd70656=true
set -o nounset -o errexit

temp_dir_path="$(mktemp -d)"
output_path="$temp_dir_path"/output.txt
shown_path="$temp_dir_path"/shown.txt

cleanup() {
  for _ in $(seq 10)
  do
    if rm -fr "$temp_dir_path" >/dev/null 2>&1
    then
      echo "Successfully removed the temporary directory." >&2
      break
    else
      echo "Failed to remove the temporary directory. Retrying in 0.1 second." >&2
    fi
    sleep 0.1
  done
}

trap cleanup EXIT

./task.cmd node js-takes-long-time.mjs "$output_path" &
producer_pid=$!

tail -F "$output_path" 2>/dev/null | tee "$shown_path" &
consumer_pid=$!

wait $producer_pid
kill $consumer_pid | :
wait $consumer_pid | :

tail -n $(($(wc -l <"$output_path") - $(wc -l <"$shown_path"))) "$output_path" | while read -r line
do
  echo "Additional: $line"
done
