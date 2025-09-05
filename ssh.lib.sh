# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_59e6a38-false}" && return 0; sourced_59e6a38=true

. ./task.sh

subcmd_ssh() {
  ssh"$(exe_ext)" "$@"
}
