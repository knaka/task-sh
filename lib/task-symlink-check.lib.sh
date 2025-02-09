#!/bin/sh
test "${guard_8986b2e+set}" = set && return 0; guard_8986b2e=x
set -o nounset -o errexit

. ./task.sh

ln -sf target "$(temp_dir_path)"/symlink
if ! test -L "$(temp_dir_path)"/symlink
then
  echo "Failed to create symlink." >&2
  if is_win
  then
    echo "To enable symlink creation on Windows, enable Developer Mode or run as Administrator." >&2
  fi
  exit 1
fi
