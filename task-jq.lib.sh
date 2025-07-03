# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_f2524bb-false}" && return 0; sourced_f2524bb=true

# jqlang/jq: Command-line JSON processor https://github.com/jqlang/jq

. ./task.sh

register_cmd \
  --brew-id=jq \
  --winget-id=stedolan.jq \
  jq \
  "$LOCALAPPDATA"/Microsoft/WinGet/Packages/jq.exe \
  #nop

jq() {
  run_registered_cmd jq "$@"
}

subcmd_jq() { # Run jq(1).
  jq "$@"
}
