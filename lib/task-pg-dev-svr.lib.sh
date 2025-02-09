#!/bin/sh
set -o nounset -o errexit

test "${guard_91ccbee+set}" = set && return 0; guard_91ccbee=x

. ./task.sh
. ./task-pgclt.lib.sh
. ./task-pgsvr.lib.sh

# ------------------------------------------------------------------------------

# Checks if the key is a dynamic entry (.i.e. the key is in .env.dynamic or not).
is_dynamic_entry() (
  key="$1"
  if ! test -r .env.dynamic
  then
    return 1
  fi
  grep -q -E "^$key=" .env.dynamic
)

# Deletes a dynamic entry from .env.dynamic.
delete_dynamic_entry() (
  if ! test -r .env.dynamic
  then
    return 0
  fi
  key="$1"
  sed -i '' -E -e "/^$key=/d" .env.dynamic
)

# Unsets a dynamic entry.
unset_dynamic_entry() {
  key_4cee18d="$1"
  if is_dynamic_entry "$key_4cee18d"
  then
    delete_dynamic_entry "$key_4cee18d"
    eval "unset $key_4cee18d"
  fi
}

# Adds a dynamic entry to .env.dynamic.
add_dynamic_entry() (
  key="$1"
  val="$2"
  delete_dynamic_entry "$key"
  echo "$key=$val" >>.env.dynamic
)

# Sets a dynamic entry.
set_dynamic_entry() {
  key_67d9a4f="$1"
  val_5d77cea="$2"
  if eval "test ! \"\${$key_67d9a4f+set}\" = set"
  then
    add_dynamic_entry "$key_67d9a4f" "$val_5d77cea"
    eval "export $key_67d9a4f=$val_5d77cea"
  fi
}

# ------------------------------------------------------------------------------

# Checks if the port is available.
is_available_port() (
  port="$1"
  if is_windows
  then
    echo "Not implemented" >&2
    return 1
    # netstat -anp | ...
  elif is_darwin
  then
    if netstat -anvp tcp | grep ^tcp4 | awk '{ print $4 }' | sed 's/.*\.//' | grep -q "^$port\$"
    then
      return 1
    fi
    return 0
  fi
  echo "Not implemented" >&2
  return 1
)

# Finds a free port.
find_free_port() (
  port_base=10000
  if test "${1+set}" = set
  then
    port_base="$1"
  fi
  for port in $(seq "$port_base" "$((port_base + 100))")
  do
    if is_available_port "$port"
    then
      echo "$port"
      break
    fi
  done
)

# ------------------------------------------------------------------------------

pg_dev_prompt() {
  while true
  do
    echo
    echo "PostgreSQL Development DB:"
    menu_item "* Launch &CLI"
    menu_item "* &Status"
    menu_item "* E&xit"
    # shellcheck disable=SC2119
    case "$(get_key)" in
      c) task_pg__cli ;;
      s) task_pg__status ;;
      x) break ;;
      *) ;;
    esac
  done
}

task_pg__dev() { # Start PostgreSQL DB (creates DB cluster if not exists).
  load_env
  if ! test "${PGPORT+set}" = set
  then
    set_dynamic_entry PGPORT "$(find_free_port 20000)"
  fi
  task_pg__cluster__create || :
  if ! task_pg__status
  then
    modify_postgresql_conf
    task_pg__start
  fi
  pg_dev_prompt
  task_pg__stop
  unset_dynamic_entry PGPORT
}
