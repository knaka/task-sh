#!/bin/sh
set -o nounset -o errexit

. "$(dirname "$0")"/task.sh

# `idea.bat` launches the IDE with java.exe, not idea64.exe. Which confuses AHK.
ide_cmd_path() {
  find \
    "C:/Program Files"/JetBrains/IntelliJ*/bin/idea64.exe | sort -rn | while read -r dir_path
  do
    if test -f "$dir_path"
    then
      echo "$dir_path"
      return 0
    fi
  done
  exit 1
}

if is_windows
then
  cross_exec "$(ide_cmd_path)" "$@"
fi

exec idea "$@"
