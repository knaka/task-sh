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
