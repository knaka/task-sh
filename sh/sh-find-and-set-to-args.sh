#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_16cbb92-}" = true && return 0; sourced_16cbb92=true
set -o nounset -o errexit

. ./task.sh

push_ifs
set_ifs_newline
# set -- $(find "/hoge/" -type f)
set --
printf "* %s\n" "$@"
echo "$#"
pop_ifs
