#!/bin/sh
set -o nounset -o errexit

test "${guard_97694a1+set}" = set && return 0; guard_97694a1=-

. task.sh

set_sync_ignored "$SCRIPT_DIR"/.git

subcmd_git() ( # Run git command.
  chdir_script
  if ! test -r .git/HEAD
  then
    git init
    set_sync_ignored "$SCRIPT_DIR"/.git
    git remote add origin git@github.com:knaka/src.git
    git fetch origin main
    git reset --hard origin/main
    git branch --set-upstream-to=origin/main main
  fi
  git "$@"
)
