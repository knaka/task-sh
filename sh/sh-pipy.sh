#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_ed02fb5-}" = true && return 0; sourced_ed02fb5=true
set -o nounset -o errexit

# temp_file_path="$(mktemp)"

# (
#   for _ in 1 2 3
#   do
#     sleep 1
#     echo "Hello, world!"
#   done 
# ) >"$temp_file_path" 2>&1 &
# producer_pid=$!

# tail -f "$temp_file_path" &
# consumer_pid=$!

# wait $producer_pid
# kill "$consumer_pid" | : 
# wait $consumer_pid | :

# # This does not show any output till the end of the loop
# cat -n <<EOF
# $(
#   for _ in 1 2 3
#   do
#     sleep 1
#     echo "Hello, world!"
#   done
# )
# EOF