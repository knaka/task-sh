# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_55c84c8-false}" && return 0; sourced_55c84c8=true

. ./task.sh

require_pkg_cmd \
  --brew-id=fswatch \
  --winget-id=emcrisostomo.fswatch \
  /usr/local/bin/fswatch \
  "$LOCALAPPDATA"/Microsoft/WinGet/Links/fswatch.exe \
  fswatch

fswatch() {
  run_pkg_cmd fswatch "$@"
}

# Run fswatch(1).
subcmd_fswatch() {
  fswatch "$@"
}
