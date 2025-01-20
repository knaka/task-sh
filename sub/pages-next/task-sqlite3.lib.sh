#!/bin/sh
set -o nounset -o errexit

test "${guard_20b5636+set}" = set && return 0; guard_20b5636=-

. ./task.sh

subcmd_sqlite3() ( # Run Sqlite3.
  run_pkg_cmd \
    --cmd=sqlite3 \
    --brew-id=sqlite \
    --winget-id=SQLite.SQLite \
    --winget-cmd-path="$HOME"/AppData/Local/Microsoft/WinGet/Links/sqlite3.exe \
    -- \
    "$@"
)
