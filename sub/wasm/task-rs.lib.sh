#!/bin/sh
set -o nounset -o errexit

test "${guard_87ee349+set}" = set && return 0; guard_87ee349=x

. ./task.sh

mkdir_sync_ignored target
mkdir_sync_ignored .bin
mkdir_sync_ignored .idea

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
      echo "$cargo_bin_path"
      return 0
    fi
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s - -y
  fi 
  echo "$cargo_bin_path"
}

set_rs_bin_env() {
  test "${guard_1e7b58b+set}" = set && return 0; guard_1e7b58b=x
  PATH="$(rs_bin_dir):$PATH"
  export PATH
}

cargo_local_bin_path() (
  dir="$SCRIPT_DIR"/target/bin
  mkdir -p "$dir"
  echo "$dir"
)

set_cargo_path() {
  test "${guard_7f2c09a+set}" = set && return 0; guard_7f2c09a=x
  PATH="$(cargo_local_bin_path):$(cargo_bin_path):$PATH"
  if is_windows
  then
    # Any smarter way to do this?
    # pacman -S --needed base-devel mingw-w64-x86_64-toolchain
    PATH="c:/msys64/usr/bin:c:/msys64/mingw64/bin:$PATH"
  fi
  export PATH  
}

subcmd_rustup() (
  set_cargo_path
  rustup "$@"
)

ensure_cargo_subcmd_bin() {
  if ! type cargo-bin >/dev/null 2>&1
  then
    subcmd_cargo install cargo-run-bin
  fi
}

subcmd_cargo() {
  set_cargo_path
  if test "${1+set}" = set && type "ensure_cargo_subcmd_$1" >/dev/null 2>&1
  then
    "ensure_cargo_subcmd_$1"
  fi
  cargo --color never "$@" 
  # cargo "$@" --color never | cat
}

subcmd_rustc() (
  set_cargo_path
  rustc "$@"
)
