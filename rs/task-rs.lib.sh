#!/bin/sh
set -o nounset -o errexit

test "${guard_87ee349+set}" = set && return 0; guard_87ee349=x

. task.sh

(
  for dir in target .idea
  do
    mkdir -p "$dir"
    set_sync_ignored "$dir"
  done
)

cargo_bin_path() {
  if type rustup >/dev/null 2>&1
  then
    dirname "$(which rustup)"
    return 0
  fi
  cargo_bin_path=$HOME/.cargo/bin
  if ! type "$cargo_bin_path"/rustup >/dev/null 2>&1
  then
    if is_windows
    then
      winget install -e --id Rustlang.Rustup
      return 1
    fi
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s - -y
  fi 
  echo "$cargo_bin_path"
}

set_cargo_path() {
  test "${guard_7f2c09a+set}" = set && return 0; guard_7f2c09a=x
  PATH="$(cargo_bin_path):$PATH"
  export PATH  
}

subcmd_rustup() (
  set_cargo_path
  rustup "$@"
)

subcmd_cargo() (
  set_cargo_path
  cargo "$@" --color never | cat
)

subcmd_rustc() (
  set_cargo_path
  rustc "$@"
)
