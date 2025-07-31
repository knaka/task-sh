#!/bin/sh
test "${guard_572d642+set}" = set && return 0; guard_572d642=-

# sqlc-dev/sqlc: Generate type-safe code from SQL https://github.com/sqlc-dev/sqlc

. ./task.sh

# Releases · sqlc-dev/sqlc https://github.com/sqlc-dev/sqlc/releases
sqlc_version_0d37f4b="1.28.0"

set_sqlc_version() {
  sqlc_version_0d37f4b="$1"
}

sqlc() {
  # shellcheck disable=SC2016
  run_fetched_cmd \
    --name="sqlc" \
    --ver="$sqlc_version_0d37f4b" \
    --os-map="$goos_map" \
    --arch-map="$goarch_map" \
    --ext-map="$archive_ext_map" \
    --url-template='https://github.com/sqlc-dev/sqlc/releases/download/v${ver}/sqlc_${ver}_${os}_${arch}${ext}' \
    --rel-dir-template="." \
    -- \
    "$@"
}

subcmd_sqlc() { # Run sqlc(1).
  sqlc "$@"
}
