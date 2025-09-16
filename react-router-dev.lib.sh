# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_4463ee4-false}" && return 0; sourced_4463ee4=true

. ./react-router.lib.sh
. ./ip-utils.lib.sh

rr_dev() {
  local host=127.0.0.1
  local port=0
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (host) brew_id=$OPTARG;;
      (port) deb_id=$OPTARG;;
      (\?) exit 1;;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))
  if test "$port" -eq 0
  then
    port="$(ip_random_free_port)"
  fi
  set -- dev --host="$host" --port="$port" "$@"
  local url="http://$host:$port"
  if ! test -t 0
  then
    react_router "$@"
    return $?
  fi
  react_router "$@" --invocation-mode=background </dev/null
  wait_for_server "$url"
  while :
  do
    echo
    menu \
      "&Browse $url" \
      "&Clear console" \
      "E&xit"
    case "$(get_key)" in
      (b) browse "$url";;
      (c) clear;;
      (x) break;;
      (*) ;;
    esac
  done
}

# Start React-Router development server
task_rr__dev() {
  rr_dev "$@"
}
