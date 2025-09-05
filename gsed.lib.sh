# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_45554c5-false}" && return 0; sourced_45554c5=true

subcmd_gsed() {
  run_pkg_cmd \
    --cmd=gsed \
    --brew-id=gnu-sed \
    -- "$@"
}
