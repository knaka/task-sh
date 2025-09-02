#!/usr/bin/env sh
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

# Idempotent SQLite3 DB schema management by SQL.
subcmd_sqlite3def() {
  # shellcheck disable=SC2016
  run_fetched_cmd \
    --name="sqlite3def" \
    --ver="$sqldef_version_c9fe5d4" \
    --os-map="$goos_map" \
    --arch-map="$goarch_map" \
    --ext=".zip" \
    --url-template='https://github.com/sqldef/sqldef/releases/download/${ver}/sqlite3def_${os}_${arch}${ext}' \
    -- \
    "$@"
}

. ./gorun.lib.sh

# Idempotent PostgreSQL DB schema management by SQL.
subcmd_psqldef() {
  subcmd_gorun github.com/sqldef/sqldef/cmd/psqldef@"$sqldef_version_c9fe5d4" "$@"
}

# Idempotent MySQL DB schema management by SQL.
subcmd_mysqldef() {
  subcmd_gorun github.com/sqldef/sqldef/cmd/mysqldef@"$sqldef_version_c9fe5d4" "$@"
}

# Idempotent MSSQL DB schema management by SQL.
subcmd_mssqldef() {
  subcmd_gorun github.com/sqldef/sqldef/cmd/mssqldef@"$sqldef_version_c9fe5d4" "$@"
}

# Old version for Windows can need Docker to work.
# subcmd_psqldef() (
#   # sqldef/sqldef: Idempotent schema management for MySQL, PostgreSQL, and more https://github.com/sqldef/sqldef
#   package=github.com/sqldef/sqldef/cmd/psqldef
#   name="$(basename "$package")"
#   version=v0.17.19

#   if ! is_windows
#   then
#     gopath="$(subcmd_go env GOPATH)"
#     bin_dir_path="$gopath"/bin
#     bin_path="$bin_dir_path"/"$name"@"$version""$(exe_ext)"
#     if ! type "$bin_path" > /dev/null 2>&1
#     then
#       subcmd_go install "$package"@"$version"
#       mv "$bin_dir_path"/"$name""$(exe_ext)" "$bin_path"
#     fi
#     "$bin_path" "$@"
#     return $?
#   fi

#   tag="$name:$version"
#   image_id="$(subcmd_docker images --format="{{.ID}}" "$tag")"
#   if test -z "$image_id"
#   then
#     (
#       cd "$TASKS_DIR"
#       subcmd_docker build --progress plain -t "$tag" -f "$name".Dockerfile --build-arg "version=$version" .
#     )
#   fi
#   for arg in "$@"
#   do
#     arg="$(echo "$arg" | sed -e 's/\blocalhost\b/host.docker.internal/g')"
#     arg="$(echo "$arg" | sed -e 's/127.0.0.1/host.docker.internal/g')"
#     set -- "$@" "$arg"
#     shift
#   done
#   subcmd_docker run -v "$PWD":/work --rm --interactive --tty "$tag" "$@"
# )
