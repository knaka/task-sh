#!/bin/sh
set -o nounset -o errexit

test "${guard_20b5636+set}" = set && return 0; guard_20b5636=-

. task.sh

subcmd_sqlite3() ( # Run Sqlite3.
  cmd=sqlite3
  winget_cmd_path="$HOME"/AppData/Local/Microsoft/WinGet/Links/sqlite3.exe
  run_installed \
    --cmd="$cmd" \
    --brew-id=sqlite \
    --winget-id=SQLite.SQLite \
    --winget-cmd-path="$winget_cmd_path"
  if is_windows
  then
    "$winget_cmd_path" "$@"
    return $?
  fi
  "$cmd" "$@"
)
