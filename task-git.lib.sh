#!/bin/sh

set_dir_sync_ignored "$(dirname "$0")"/.git

subcmd_git() { # Run git command.
  cd "$(dirname "$0")" || exit 1
  if ! test -d .git
  then
    git init
    git remote add origin git@github.com:knaka/src.git
    git branch --set-upstream-to=origin/main main
    git fetch origin
  fi
  exec git "$@"
}
