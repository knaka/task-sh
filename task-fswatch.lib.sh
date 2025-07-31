# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_55c84c8-false}" && return 0; sourced_55c84c8=true

. ./task.sh

require_pkg_cmd \
  --brew-id=fswatch \
  --winget-id=emcrisostomo.fswatch \
  fswatch \
  "$LOCALAPPDATA"/Microsoft/fswatch/Packages/fswatch.exe

fswatch() {
  run_pkg_cmd fswatch "$@"
}

subcmd_fswatch() { # Run fswatch(1).
  fswatch "$@"
}
