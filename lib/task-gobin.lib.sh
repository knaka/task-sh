#!/bin/sh
test "${guard_fa77b11+set}" = set && return 0; guard_fa77b11=-

. ./task.sh

subcmd_gobin() { # Run the gobin command.
  if ! test -r Gobinfile
  then
    echo "Gobinfile not found in the project root." >&2
    exit 1
  fi
  local bin_dir_path="$HOME"/.bin
  local app_dir_path="$bin_dir_path"/gobin
  local cmd_ext=
  if is_windows
  then
    cmd_ext=".cmd"
  fi
  if ! test -x "$app_dir_path"/cmd-gobin$cmd_ext
  then
    mkdir -p "$app_dir_path"
    cross_run curl --fail --location --output "$app_dir_path"/cmd-gobin$cmd_ext https://raw.githubusercontent.com/knaka/gobin/main/bootstrap/cmd-gobin$cmd_ext
    chmod +x "$app_dir_path"/cmd-gobin$cmd_ext
  fi
  "$app_dir_path"/cmd-gobin$cmd_ext "$@"
}
