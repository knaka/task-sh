#!/bin/sh
set -o nounset -o errexit

test "${guard_f34235f+set}" = set && return 0; guard_f34235f=x

. "$(dirname "$0")"/task.sh

cmd_path=kindle
if is_windows
then
  cmd_path="$HOME"/AppData/Local/Amazon/Kindle/application/Kindle.exe
  if ! test -e "$cmd_path"
  then
    unset USERPROFILE
    unset HOMEPATH
    unset HOME
    winget install -e --id Amazon.Kindle
  fi
  cross_run "$cmd_path" "$@" &
  exit $?
elif is_darwin
then
  path="/Applications/Amazon Kindle.app"
  if ! test -d "$path"
  then
    echo "Amazon Kindle.app not found in /Applications"
    exit 1
  fi
  open "$path" "$@"
  exit $?
fi

