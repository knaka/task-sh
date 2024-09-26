#!/bin/sh
set -o nounset -o errexit

set_dir_sync_ignored .idea build
  
delegate_tasks() (
  ORIGINAL_WD="$PWD"
  export ORIGINAL_WD
  cd "$(dirname "$0")" || exit 1
  cmd=build/60f20fa"$(exe_ext)"
  files=""
  for file in task.go task-*.go
  do
    if test -r "$file"
    then
      files="$files $file"
    fi
  done
  if ! test -x "$cmd"
  then
    # shellcheck disable=SC2086
    sh task.sh go build -o "$cmd" $files
  fi
  for file in $files
  do 
    if is_newer_than "$file" "$cmd"
    then
      # shellcheck disable=SC2086
      sh task.sh go build -o "$cmd" $files
      break
    fi
  done
  $cmd "$@"
)
