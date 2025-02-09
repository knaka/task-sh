#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_548f329-}" = true && return 0; sourced_548f329=true
set -o nounset -o errexit

while read -r line
do
  echo d: "$line"
done < /etc/fstab
