# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_4463ee4-false}" && return 0; sourced_4463ee4=true

. ./react-router.lib.sh
. ./ip-utils.lib.sh

# Start React-Router development server
task_rr__dev() {
  local host=127.0.0.1
  local port="$(ip_random_free_port)"
  local url="http://$host:$port"
  INVOCATION_MODE_node=background react_router dev --host="$host" --port="$port" </dev/null
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
