# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_bb342b3-false}" && return 0; sourced_bb342b3=true

. ./task.sh

# Run bun(1).
subcmd_bun() {
  run_pkg_cmd \
    --cmd=bun \
    --brew-id=oven-sh/bun/bun \
    --winget-id=Oven-sh.Bun \
    --win-cmd-path="$HOME"/AppData/Local/Microsoft/WinGet/Links/bun.exe \
    -- "$@"
}
