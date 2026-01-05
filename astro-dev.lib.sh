# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_62b683f-false}" && return 0; sourced_62b683f=true

. ./task.sh
. ./astro.lib.sh

astro_dev() {
  export APP_ENV=development
  export NODE_ENV="$APP_ENV"
  load_env

  local host=
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

  if test -n "$host"
  then
    set -- "$@" --host "$host"
  fi
  if test "$port" -ne 0
  then
    set -- "$@" --port "$port"
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

# Launch the Astro development server.
task_astro__dev() {
  astro_dev
}
