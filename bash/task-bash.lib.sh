#!/bin/sh
set -o nounset -o errexit

# shellcheck disable=SC1091
. "$(dirname "$0")"/../utils.lib.sh

subcmd_run() {
  if ! is_windows
  then
    exec /bin/bash "$@"
  fi
  msys_dir_path=C:/msys64
  msys_bin_dir_path="$msys_dir_path"/usr/bin
  bash_cmd_path="$msys_bin_dir_path/bash.exe"
  if ! type "$bash_cmd_path" > /dev/null 2>&1
  then
    winget.exe install --exact --id=MSYS2.MSYS2
  fi
  PATH="$msys_bin_dir_path:$PATH" exec "$bash_cmd_path" "$@"
}
