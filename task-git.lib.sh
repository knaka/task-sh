#!/bin/sh

set_dir_sync_ignored "$(dirname "$0")"/.git

subcmd_git() { # Run git command.
  cd "$(dirname "$0")" || exit 1
  if ! test -r .git/HEAD
  then
    git init
    git remote add origin git@github.com:knaka/src.git
    git fetch origin main
    git reset --hard origin/main
    git branch --set-upstream-to=origin/main main
  fi
  exec git "$@"
}
