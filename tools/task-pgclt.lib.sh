#!/bin/sh
set -o nounset -o errexit

test "${guard_e099219+set}" = set && return 0; guard_e099219=x

. task.sh

psql_cmd=psql
brew_psql_cmd_path=/usr/local/opt/postgresql@15/bin/psql
winget_psql_cmd_path="$HOME"/foo/bar/psql.exe

subcmd_pg__run() (
  cmd_path=$(
    install_pkg_cmd \
      --cmd="$psql_cmd" \
      --brew-id=postgresql@15 \
      --brew-cmd-path="$brew_psql_cmd_path" \
      --winget-id=foo.bar \
      --winget-cmd-path="$winget_psql_cmd_path"
  )
  PATH="$(dirname "$cmd_path"):$PATH"
  export PATH
  "$@"
)

subcmd_psql() (
  subcmd_pg__run psql "$@"
)

subcmd_pg_dump() (
  subcmd_pg__run pg_dump "$@"
)

subcmd_pg_dumpall() (
  subcmd_pg__run pg_dumpall "$@"
)

task_pg__cli() (
  load_env
  export PGPASSWORD
  subcmd_psql \
    --host="$PGHOST" \
    --port="$PGPORT" \
    --username="$PGUSER" \
    --dbname="$PGDATABASE" \
    "$@"
)

subcmd_pg__dump() (
  load_env
  export PGPASSWORD
  subcmd_pg_dump \
    --host="$PGHOST" \
    --port="$PGPORT" \
    --username="$PGUSER" \
    --dbname="$PGDATABASE" \
    "$@"
)

subcmd_pg__dumpall() (
  load_env
  export PGPASSWORD
  subcmd_pg_dumpall \
    --host="$PGHOST" \
    --port="$PGPORT" \
    --username="$PGUSER" \
    "$@"
)
