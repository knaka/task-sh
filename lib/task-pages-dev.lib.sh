# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_5268aba-}" = true && return 0; sourced_5268aba=true

. ./task-pages.lib.sh

task_pages__dev() { # Launch the Wrangler Pages development server.
  export APP_ENV=development
  load_env
  task_pages__functions__watchbuild --invocation-mode=background
  test "${PAGES_DEV_PORT+set}" = set && set -- "$@" --port "$PAGES_DEV_PORT"
  test "${PAGES_WEB_PORT+set}" = set && set -- "$@" --binding PAGES_WEB_PORT="$PAGES_WEB_PORT"
  task_put_pages_routes_json
  subcmd_wrangler pages dev --live-reload "$@"
}
