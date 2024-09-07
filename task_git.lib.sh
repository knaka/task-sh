#!/bin/sh

: "${script_dir_path:=}"

# shellcheck disable=SC1091
. "$script_dir_path"/task_attributes.lib.sh

subcmd_git() { # Run git command.
  cd "$script_dir_path" || exit 1
  if ! test -d .git
  then
    git init
    set_path_sync_ignored .git/
    git remote add origin git@github.com:knaka/scr.git
    git branch --set-upstream-to=origin/main main
    git fetch origin
  fi
  exec git "$@"
}
