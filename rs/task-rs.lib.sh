#!/bin/sh
set -o nounset -o errexit

test "${guard_87ee349+set}" = set && return 0; guard_87ee349=x

. task.sh

set_dir_sync_ignored "$SCRIPT_DIR"/target

cargo_bin_path() {
  if type rustup >/dev/null 2>&1
  then
    dirname "$(which rustup)"
    return 0
  fi
  if is_windows
  then
    echo Not implemented yet >&2
    return 1
  fi
  cargo_bin_path=$HOME/.cargo/bin
  if ! type "$cargo_bin_path"/rustup >/dev/null 2>&1
  then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s - -y
  fi 
  echo "$cargo_bin_path"
}

set_cargo_path() {
  PATH="$(cargo_bin_path):$PATH"
  export PATH  
}

subcmd_rustup() (
  set_cargo_path
  rustup "$@"
)

subcmd_cargo() (
  set_cargo_path
  cargo "$@" | cat
)
