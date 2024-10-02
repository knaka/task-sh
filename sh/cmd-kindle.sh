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
    echo d: 23280f7 "$cmd_path" >&2
    unset USERPROFILE
    unset HOMEPATH
    unset HOME
    # winget install -e --id Amazon.Kindle
  fi
fi

cross_run "$cmd_path" "$@" &
