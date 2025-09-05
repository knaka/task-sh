# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_4d4e0b6-false}" && return 0; sourced_4d4e0b6=true

. ./task.sh
. ./pgclt.lib.sh
. ./pgsvr.lib.sh

# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------

# Checks if the port is available.
is_available_port() (
  port="$1"
  if is_windows
  then
    echo "Not implemented" >&2
    return 1
    # netstat -anp | ...
  elif is_macos
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

# Start PostgreSQL DB (creates DB cluster if not exists).
task_pg__dev() {
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
