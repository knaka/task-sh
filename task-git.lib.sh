#!/bin/sh

# shellcheck disable=SC1091
. "$(dirname "$0")"/task-sync-ignored.lib.sh

subcmd_git() { # Run git command.
  cd "$(dirname "$0")" || exit 1
  if ! test -d .git
  then
    git init
    git remote add origin git@github.com:knaka/src.git
    git branch --set-upstream-to=origin/main main
    git fetch origin
  fi
  set_path_sync_ignored .git/
  exec git "$@"
}
