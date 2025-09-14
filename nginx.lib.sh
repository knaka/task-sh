# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_231d488-false}" && return 0; sourced_231d488=true

. ./task.sh

require_pkg_cmd \
  --brew-id=nginx \
  --winget-id=nginxinc.nginx \
  "$LOCALAPPDATA"/Microsoft/WinGet/Links/nginx.exe \
  nginx

nginx() {
  run_pkg_cmd nginx "$@"
}
