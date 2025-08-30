# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_9c57819-}" = true && return 0; sourced_9c57819=true

. ./task.sh

require_pkg_cmd \
  --brew-id=sqlite \
  --winget-id=SQLite.SQLite \
  /usr/local/bin/sqlite3 \
  /usr/local/opt/sqlite/bin/sqlite3 \
  "$LOCALAPPDATA"/Microsoft/WinGet/Links/sqlite3.exe \
  sqlite3

sqlite3() {
  run_pkg_cmd sqlite3 "$@"
}

subcmd_sqlite3() { # Run sqlite3(1).
  sqlite3 "$@"
}
