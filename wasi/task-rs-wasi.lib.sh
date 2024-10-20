#!/bin/sh
set -o nounset -o errexit

test "${guard_205ffb3+set}" = set && return 0; guard_205ffb3=x

ensure_cargo_subcmd_component() {
  if ! type cargo-component >/dev/null 2>&1
  then
    subcmd_cargo install cargo-component
  fi
}

# shellcheck disable=SC2120
task_build() {
  subcmd_cargo component build "$@"
}

subcmd_wasmtime() {
  run_installed \
    --cmd=wasmtime \
    --brew-id=wasmtime \
    --winget-id=BytecodeAlliance.Wasmtime \
    --winget-cmd-path="$HOME"/AppData/Local/Microsoft/WinGet/Links/wasmtime.exe \
    -- \
    "$@"
}
