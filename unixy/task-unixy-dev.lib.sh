#!/bin/sh
set -o nounset -o errexit

test "${guard_83e6bff+set}" = set && return 0; guard_83e6bff=x

. ./task.sh
. ./task-unixy.lib.sh

set_unixy_dev_env() {
  test "${guard_ba3b7cb+set}" = set && return 0; guard_ba3b7cb=x
  set_unixy_env
  if is_windows
    then
    if ! test -e "C:/msys64/mingw64/bin/gcc.exe"
    then
      pacman.exe --sync --noconfirm base-devel
      pacman.exe --sync --noconfirm mingw-w64-x86_64-toolchain
    fi
    PATH="C:/msys64/mingw64/bin:$PATH"
    export PATH
  elif is_mac
  then
    if ! test -x /Library/Developer/CommandLineTools/usr/bin/gcc
    then
      xcode-select --install
    fi
    PATH="/Library/Developer/CommandLineTools/usr/bin:$PATH"
    export PATH
  fi
}

subcmd_gcc() {
  set_unixy_dev_env
  cross_exec gcc "$@"
}
