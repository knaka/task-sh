#!/bin/sh
set -o nounset -o errexit

test "${guard_20b5636+set}" = set && return 0; guard_20b5636=-

. task.sh

subcmd_sqlite3() ( # Run Sqlite3.
  run_installed \
    --name=sqlite3 \
    --winget-id=SQLite.SQLite \
    --winget-path="$HOME"/AppData/Local/Microsoft/WinGet/Links/sqlite3.exe \
    -- "$@"
)
