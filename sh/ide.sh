#!/bin/sh
set -o nounset -o errexit

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

exec "$(ide_cmd_path)" "$@" &
