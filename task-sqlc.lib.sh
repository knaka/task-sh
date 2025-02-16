#!/bin/sh
test "${guard_572d642+set}" = set && return 0; guard_572d642=-

# sqlc-dev/sqlc: Generate type-safe code from SQL https://github.com/sqlc-dev/sqlc

. ./task-gorun.lib.sh

# Tags · sqlc-dev/sqlc https://github.com/sqlc-dev/sqlc/tags
: "${sqlc_version:=v1.28.0}"

set_sqlc_version() {
  sqlc_version="$1"
}

subcmd_sqlc() { # Generates type-safe code from SQL. https://github.com/sqlc-dev/sqlc
  subcmd_gorun github.com/sqlc-dev/sqlc/cmd/sqlc@"$sqlc_version" "$@"
}
