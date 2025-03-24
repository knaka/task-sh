#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_8a52dac-}" = true && return 0; sourced_8a52dac=true
set -o nounset -o errexit

. ./task.sh
. ./task-astro.lib.sh

task_astro__dev() { # Launch the Astro development server.
  export APP_ENV=development
  export NODE_ENV="$APP_ENV"
  load_env
  local host="${ASTRO_DEV_HOST:-127.0.0.1}"
  local port="${ASTRO_DEV_PORT:-3000}"
  set -- "$@" --host "$host"
  set -- "$@" --port "$port"
  if test "${ASTRO_DYNAMIC_PORT+set}" = set
  then
    export ASTRO_DYNAMIC_PORT
  fi
  local log_path
  log_path="$TEMP_DIR"/astro-dev.log
  subcmd_astro --invocation-mode=background dev "$@" >"$log_path"
  invoke --invocation-mode=background tail -F "$log_path"
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
      "E&xit"
    case "$(get_key)" in
      (b) browse "http://$host:$port" ;;
      (c) clear ;;
      (x) break ;;
      (*) ;;
    esac
  done
}
