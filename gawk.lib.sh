# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_3b065da-false}" && return 0; sourced_3b065da=true

. ./task.sh

subcmd_gawk() {
  run_pkg_cmd \
    --cmd=gawk \
    --brew-id=gawk \
    -- "$@"
}
