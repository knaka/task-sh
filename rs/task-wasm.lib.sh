#!/bin/sh
set -o nounset -o errexit

test "${guard_11b6766+set}" = set && return 0; guard_11b6766=x

. task-rs.lib.sh

subcmd_wasm() { # Run wasm-pack.
  if ! subcmd_rustup toolchain list | grep -q wasm32-
  then
    subcmd_rustup target add wasm32-unknown-unknown
  fi
  subcmd_cargo bin wasm-pack "$@"
}
