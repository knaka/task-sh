#!/bin/sh
set -o nounset -o errexit

test "${guard_8ad9fcF+set}" = set && return 0; guard_8ad9fcF=x

. ./task.sh

set_unixy_env() {
  test "${guard_1b4eb49+set}" = set && return 0; guard_1b4eb49=x
  if is_windows
  then
    if ! test -e "C:/msys64/usr/bin/bash.exe"
    then
      winget.exe install --exact --id=MSYS2.MSYS2
    fi
    PATH="C:/msys64/usr/bin:$PATH"
    export PATH
  fi
}

subcmd_bash() {
  set_unixy_env
  cross_exec bash "$@"
}
