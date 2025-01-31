# vim: set filetype=sh :
# shellcheck shell=sh
test "${sourced_40243ec-}" = true && return 0; sourced_40243ec=true
set -o nounset -o errexit

. ./task.sh

subcmd_curl() { # Run curl(1).
  run_pkg_cmd \
    --cmd=curl \
    --dpkg-id=curl \
    -- "$@"
}
