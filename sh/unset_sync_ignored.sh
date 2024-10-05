#!/bin/sh
set -o nounset -o errexit

test "${guard_bb5832d+set}" = set && return 0; guard_bb5832d=x

. "$(dirname "$0")"/task.sh

unset_path_attr() (
  path="$1"
  attribute="$2"
  if which xattr > /dev/null 2>&1
  then
    xattr -d "$attribute" "$path"
  elif which PowerShell > /dev/null 2>&1
  then
    powershell -Command "Clear-ItemProperty -Path '$path' -Name '$attribute'"
  elif which attr > /dev/null 2>&1
  then
    attr -r -s "$attribute" "$path"
  else
    echo "No supported command found to unset attribute '$attribute' on path '$path'" >&2
    return 1
  fi
)

# shellcheck disable=SC2154
for attribute in $file_sharing_ignorance_attributes
do
  unset_path_attr "$1" "$attribute"
done
