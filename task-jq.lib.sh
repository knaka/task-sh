# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_f2524bb-false}" && return 0; sourced_f2524bb=true

# jqlang/jq: Command-line JSON processor https://github.com/jqlang/jq

. ./task.sh

require_pkg_cmd \
  --brew-id=jq \
  --winget-id=jqlang.jq \
  /usr/local/bin/jq \
  "$LOCALAPPDATA"/Microsoft/WinGet/Links/jq.exe \
  jq

jq() {
  run_pkg_cmd jq "$@"
}

desc_jq="Run jq(1)."
subcmd_jq() {
  jq "$@"
}
