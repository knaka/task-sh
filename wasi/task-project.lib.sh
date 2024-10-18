#!/bin/sh
set -o nounset -o errexit

test "${guard_5ed9b98+set}" = set && return 0; guard_5ed9b98=x

. task.sh

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

subcmd_run() {
  subcmd_wasmtime target/wasm32-wasip1/debug/wasimain.wasm
}
