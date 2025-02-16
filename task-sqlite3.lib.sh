# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_9c57819-}" = true && return 0; sourced_9c57819=true

. ./task.sh

subcmd_sqlite3() { # Run Sqlite3.
  run_pkg_cmd \
    --cmd=sqlite3 \
    --brew-id=sqlite \
    --win-cmd-path="$HOME"/AppData/Local/Microsoft/WinGet/Links/sqlite3.exe \
    --winget-id=SQLite.SQLite \
    -- \
    "$@"
}
