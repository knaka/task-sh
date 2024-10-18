#!/bin/sh
set -o nounset -o errexit

test "${guard_205ffb3+set}" = set && return 0; guard_205ffb3=x

ensure_cargo_subcmd_component() {
  if ! type cargo-component >/dev/null 2>&1
  then
    subcmd_cargo install cargo-component
  fi
}
