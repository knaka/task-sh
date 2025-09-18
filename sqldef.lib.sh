# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_3cd56df-false}" && return 0; sourced_3cd56df=true

# sqldef/sqldef: Idempotent schema management for MySQL, PostgreSQL, and more https://github.com/sqldef/sqldef

# Tags · sqldef/sqldef https://github.com/sqldef/sqldef/tags
: "${sqldef_version_c9fe5d4:=v2.0.10}"

set_sqldef_version() {
  sqldef_version_c9fe5d4="$1"
}

. ./task.sh

sqldef() {
  local name="$1"
  shift
  # shellcheck disable=SC2016
  run_fetched_cmd \
    --name="$name" \
    --ver="$sqldef_version_c9fe5d4" \
    --os-map="$goos_map" \
    --arch-map="$goarch_map" \
    --ext=".zip" \
    --url-template='https://github.com/sqldef/sqldef/releases/download/${ver}/${name}_${os}_${arch}${ext}' \
    -- \
    "$@"
}

sqlite3def() {
  sqldef sqlite3def "$@"
}

# Idempotent SQLite3 DB schema management by SQL.
subcmd_sqlite3def() {
  sqlite3def "$@"
}

psqldef() {
  sqldef psqldef "$@"
}

# Idempotent PostgreSQL DB schema management by SQL.
subcmd_psqldef() {
  psqldef "$@"
}
