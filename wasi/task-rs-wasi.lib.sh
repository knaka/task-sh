#!/bin/sh
set -o nounset -o errexit

test "${guard_205ffb3+set}" = set && return 0; guard_205ffb3=x

. task.sh

mkdir_sync_ignored .vscode

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
  run_pkg_cmd \
    --cmd=wasmtime \
    --brew-id=wasmtime \
    --winget-id=BytecodeAlliance.Wasmtime \
    --winget-cmd-path=C:/"Program Files"/Wasmtime/bin/wasmtime.exe \
    -- \
    "$@"
}

# Needs?:
#   /msys64/usr/bin/pacman --sync -y --needed base-devel mingw-w64-x86_64-toolchain