#!/bin/sh
test "${guard_932ee57+set}" = set && return 0; guard_932ee57=-

. ./task.sh

subcmd_gorun() { # Run gorun.
  local bin_dir_path="$HOME"/.bin
  local cmd_ext=
  if is_windows
  then
    cmd_ext=.cmd
  fi
  local cmd_path="$bin_dir_path"/gorun"$cmd_ext"
  if ! test -x "$cmd_path"
  then
    cross_run curl --fail --location --output "$cmd_path" https://raw.githubusercontent.com/knaka/gorun/refs/heads/main/gorun"$cmd_ext"
    chmod +x "$cmd_path"
  fi
  "$cmd_path" "$@"
}
