#!/bin/sh
test "${guard_fb8b13a+set}" = set && return 0; guard_fb8b13a=x

. ./task.sh
. ./task-volta.lib.sh
. ./task-pages.lib.sh
. ./task-astro.lib.sh

# --------------------------------------------------------------------------
# Development
# --------------------------------------------------------------------------

task_pages__dev() { # Launch the Wrangler Pages development server.
  export NODE_ENV=development
  load_env
  sh task.sh task_worker__watchbuild &
  test "${PAGES_DEV_PORT+set}" = set && set -- "$@" --port "$PAGES_DEV_PORT"
  test "${ASTRO_DEV_PORT+set}" = set && set -- "$@" --binding AP_DEV_PORT="$ASTRO_DEV_PORT"
  subcmd_wrangler pages dev "$@" --live-reload ./dist
}

task_astro__dev() { # Launch the Astro development server.
  export NODE_ENV=development
  load_env
  set -- "$@" --host "${ASTRO_DEV_HOST:-127.0.0.1}"
  set -- "$@" --port "${ASTRO_DEV_PORT:-3000}"
  if test "${PAGES_DEV_PORT+set}" = set
  then
    export API_DEV_PORT="$PAGES_DEV_PORT"
  fi
  local log_path
  log_path="$(temp_dir_path)"/astro-dev.log
  sh task.sh subcmd_astro dev "$@" </dev/null 2>&1 | tee "$log_path" &
  while true
  do
    sleep 1
    if grep -q "watching for file changes" "$log_path" > /dev/null 2>&1
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
      (b) open_browser "http://$host:$port" ;;
      (c) clear ;;
      (l) task_astro__build ;;
      (x) break ;;
      (*) ;;
    esac
  done
}
