#!/bin/sh
set -o nounset -o errexit

test "${guard_a543be5+set}" = set && return 0; guard_a543be5=x

. ./task.sh
. ./task-pgclt.lib.sh

subcmd_pg_ctl() (
  subcmd_pg__run pg_ctl "$@"
)

subcmd_initdb() (
  subcmd_pg__run initdb "$@"
)

modify_postgresql_conf() (
  sed -i '' -E -e "s/^#?port =.*$/port = $PGPORT/" "$SCRIPT_DIR"/pgdata/postgresql.conf
  sed -i '' -E -e "s/^#?listen_addresses =.*$/listen_addresses = '$PGHOST'/" "$SCRIPT_DIR"/pgdata/postgresql.conf
)

task_pg__cluster__create() (
  chdir_script
  if test -d pgdata/base
  then
    echo "Database cluster already exists." >&2
    return 1
  fi
  load_env
  temp_dir_path_d9f5174=$(mktemp -d)
  echo "$PGPASSWORD" > "$temp_dir_path_d9f5174"/password.txt
  subcmd_initdb \
    --pgdata "$SCRIPT_DIR"/pgdata \
    --auth=md5 \
    --username="$PGUSER" --pwfile="$temp_dir_path_d9f5174"/password.txt \
    --no-locale \
    --encoding=UTF8
  rm -fr "$temp_dir_path_d9f5174"
  modify_postgresql_conf
)

task_pg__cluster__drop() (
  chdir_script
  task_pg__stop || :
  rm -fr pgdata/*
)

task_pg__start() (
  chdir_script
  if ! test -d pgdata/base
  then
    echo "Database cluster does not exist." >&2
    return 1
  fi
  subcmd_pg_ctl -D "$SCRIPT_DIR"/pgdata -l "$SCRIPT_DIR"/pgdata/logfile start
)

task_pg__stop() (
  chdir_script
  subcmd_pg_ctl -D "$SCRIPT_DIR"/pgdata stop
)

task_pg__status() (
  chdir_script
  subcmd_pg_ctl -D "$SCRIPT_DIR"/pgdata status
)
