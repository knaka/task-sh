#!/bin/sh
test "${guard_b867991+set}" = set && return 0; guard_b867991=-
set -o nounset -o errexit

. ./task-astro.lib.sh

task_astro__dev() { # Launch the Astro development server.
  export APP_ENV=development
  load_env
  local host="${ASTRO_DEV_HOST:-127.0.0.1}"
  local port="${ASTRO_DEV_PORT:-3000}"
  set -- "$@" --host "$host"
  set -- "$@" --port "$port"
  local log_path
  log_path="$(temp_dir_path)"/astro-dev.log
  sh task.sh subcmd_astro dev "$@" </dev/null 2>&1 | tee "$log_path" &
  while true
  do
    sleep 1
    if grep -q "watching for file changes" "$log_path" >/dev/null 2>&1
    then
      break
    fi
  done
  while true
  do
    menu \
      "Open a &browser" \
      "&Clear console" \
      "Bui&ld" \
      "E&xit"
    case "$(get_key)" in
      (b) open_browser "http://$host:$port";;
      (c) clear;;
      (l)
        if task_astro__build
        then
          echo "Built successfully."
        else
          echo "Failed to build."
        fi
        ;;
      (x) break;;
      (*) ;;
    esac
  done
}
