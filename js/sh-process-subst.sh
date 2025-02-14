#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_e2aa848-}" = true && return 0; sourced_e2aa848=true
set -o nounset -o errexit

./task.cmd node js-takes-long-time.mjs >(cat -n)
# cat -n <(printf "hello%d" 123)
