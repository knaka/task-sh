# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_62b683f-false}" && return 0; sourced_62b683f=true

. ./task.sh
. ./astro.lib.sh

# Launch the Astro development server.
task_astro__dev() {
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
  INVOCATION_MODE=background astro --root "$astro_project_dir_0135e32" dev "$@"
  wait_for_server "http://$host:$port"
  while true
  do
    menu \
      "Open &browser http://$host:$port" \
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
