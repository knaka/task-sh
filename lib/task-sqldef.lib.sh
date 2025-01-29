#!/bin/sh
test "${guard_1c4f762+set}" = set && return 0; guard_1c4f762=-

# sqldef/sqldef: Idempotent schema management for MySQL, PostgreSQL, and more https://github.com/sqldef/sqldef

. ./task-gorun.lib.sh

# Tags · sqldef/sqldef https://github.com/sqldef/sqldef/tags
: "${sqldef_version:=v0.17.29}"

set_sqldef_version() {
  sqldef_version="$1"
}

subcmd_psqldef() { # Idempotent PostgreSQL DB schema management by SQL.
  subcmd_gorun github.com/sqldef/sqldef/cmd/psqldef@"$sqldef_version" "$@"
}

subcmd_mysqldef() { # Idempotent MySQL DB schema management by SQL.
  subcmd_gorun github.com/sqldef/sqldef/cmd/mysqldef@"$sqldef_version" "$@"
}

subcmd_sqlite3def() { # Idempotent SQLite3 DB schema management by SQL.
  subcmd_gorun github.com/sqldef/sqldef/cmd/sqlite3def@"$sqldef_version" "$@"
}

subcmd_mssqldef() { # Idempotent MSSQL DB schema management by SQL.
  subcmd_gorun github.com/sqldef/sqldef/cmd/mssqldef@"$sqldef_version" "$@"
}
