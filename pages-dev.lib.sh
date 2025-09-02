# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_5268aba-}" = true && return 0; sourced_5268aba=true

. ./pages.lib.sh

# Launch the Wrangler Pages development server.
task_pages__dev() {
  export APP_ENV=development
  export NODE_ENV="$APP_ENV"
  load_env
  test "${PAGES_DEV_PORT+set}" = set && set -- "$@" --port "$PAGES_DEV_PORT"
  test "${PAGES_CONTENT_PORT+set}" = set && set -- "$@" --binding PAGES_CONTENT_PORT="$PAGES_CONTENT_PORT"
  task_pages__routes_json__put
  subcmd_wrangler pages dev --live-reload "$@"
}
