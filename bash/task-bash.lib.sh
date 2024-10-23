#!/bin/sh
set -o nounset -o errexit

test "${guard_8ad9fcF+set}" = set && return 0; guard_8ad9fcF=x

set_msys_env() {
  test "${guard_1b4eb49+set}" = set && return 0; guard_1b4eb49=x
  if ! test -e "C:/msys64/usr/bin/bash.exe"
  then
    winget.exe install --exact --id=MSYS2.MSYS2
  fi
  PATH="C:/msys64/usr/bin:$PATH"
  export PATH
}

subcmd_bash() {
  if ! is_windows
  then
    cross_exec /bin/bash "$@"
  fi
  PATH="C:/msys64/usr/bin:$PATH" cross_exec bash.exe "$@"
}

set_mingw_env() {
  test "${guard_ba3b7cb+set}" = set && return 0; guard_ba3b7cb=x
  set_msys_env
  if ! test -e "C:/msys64/mingw64/bin/gcc.exe"
  then
    pacman.exe --sync --noconfirm base-devel
    pacman.exe --sync --noconfirm mingw-w64-x86_64-toolchain
  fi
  PATH="C:/msys64/mingw64/bin:$PATH"
  export PATH
}

subcmd_gcc() {
  if ! is_windows
  then
    cross_exec /usr/bin/gcc "$@"
  fi
  set_
}
