#!/bin/sh
test "${guard_c42742c+set}" = set && return 0; guard_c42742c=-

. ./task-pages.lib.sh

task_pages__dev() { # Launch the Wrangler Pages development server.
  export APP_ENV=development
  load_env
  "$SH" task.sh task_pages__functions__watchbuild &
  test "${PAGES_DEV_PORT+set}" = set && set -- "$@" --port "$PAGES_DEV_PORT"
  test "${PAGES_WEB_PORT+set}" = set && set -- "$@" --binding PAGES_WEB_PORT="$PAGES_WEB_PORT"
  subcmd_wrangler pages dev "$@" --live-reload ./dist
}
