# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_c50ed7a-false}" && return 0; sourced_c50ed7a=true

# Defining `before_pg` function in your project file allows defining necessary environment variables before running `pg:*` tasks.
# 
#   before_pg() {
#     export PGHOST=127.0.0.1
#     export PGPORT="$(sed -E -n -e 's/port *= *//p' "$PROJECT_DIR"/pgdata/postgresql.conf || echo 5432)"
#     export PGUSER=postgres
#     export PGPASSWORD=password
#     export PGDATABASE=postgres
#   }

. ./task.sh
. ./postgresql.lib.sh

pgdata_dir_00ad1e3="$PROJECT_DIR"/pgdata

set_pgdata_dir() {
  pgdata_dir_00ad1e3="$1"
}

pg_create() {
  local pgdata_dir="$pgdata_dir_00ad1e3"
  local username="${PGUSER:-postgres}"
  local password="${PGPASSWORD:-password}"
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (username) username=$OPTARG;;
      (password) password=$OPTARG;;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  if test -d "$pgdata_dir"/base
  then
    echo "Database cluster already exists." >&2
    return 1
  fi
  local pwfile="$TEMP_DIR"/6456f05
  echo "$password" >"$pwfile"
  initdb \
    --pgdata="$pgdata_dir" \
    --auth=md5 \
    --username="$username" \
    --pwfile="$pwfile" \
    --no-locale \
    --encoding=UTF8 \
    #nop
}

# Create PostgreSQL database cluster
task_pg__create() {
  pg_create "$@"
}

# Delete PostgreSQL database cluster
task_pg__delete() {
  if pg_ctl -D "$pgdata_dir_00ad1e3" status >/dev/null
  then
    echo "Server is working." >&2
    return 1
  fi
  if prompt_confirm "Do you really want to delete the database?" "no"
  then
    rm -fr "$pgdata_dir_00ad1e3"
    echo "The database was deleted." >&2
  else
    echo "The database was not deleted." >&2
    return 1
  fi
}

pg_start() {
  local pgdata_dir="$pgdata_dir_00ad1e3"
  local host=127.0.0.1
  local port=0
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (host) host=$OPTARG;;
      (port) port=$OPTARG;;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  if test "$port" -eq 0
  then
    port="$(ip_random_free_port)"
    export PGPORT="$port"
  fi
  if ! test -d "$pgdata_dir"/base
  then
    echo "Database cluster does not exist." >&2
    return 1
  fi
  sed -i '' -E \
    -e "s/^#?port =.*$/port = $port/" \
    -e "s/^#?listen_addresses =.*$/listen_addresses = '$host'/" \
    "$pgdata_dir"/postgresql.conf
  pg_ctl -D "$pgdata_dir" -l "$pgdata_dir"/logfile start
}

# Start PostgreSQL server.
task_pg__start() {
  pg_start
}

# Stop PostgreSQL server.
task_pg__stop() {
  pg_ctl -D "$pgdata_dir_00ad1e3" stop
}

# Show PostgreSQL server status.
task_pg__status() {
  pg_ctl -D "$pgdata_dir_00ad1e3" status
}

# Launch PostgreSQL CLI client (psql).
subcmd_pg__cli() {
  psql "$@"
}
