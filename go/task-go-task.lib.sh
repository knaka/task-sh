#!/bin/sh
set -o nounset -o errexit

test "${guard_c16da21+set}" = set && return 0; guard_c16da21=-

. task.sh

set_dir_sync_ignored \
  "$script_dir_path"/.idea \
  "$script_dir_path"/build
  
delegate_tasks() (
  ORIGINAL_WD="$PWD"
  export ORIGINAL_WD
  cd "$script_dir_path" || exit 1
  cmd_file=build/60f20fa"$(exe_ext)"
  task_go_files=task.go
  for task_go_file in task-*.go
  do
    if ! test -r "$task_go_file"
    then
      continue
    fi
    task_go_files="$task_go_files $task_go_file"
  done
  # shellcheck disable=SC2086
  if ! test -x "$cmd_file" || newer $task_go_files --than "$cmd_file"
  then
    # echo Building >&2
    # shellcheck disable=SC2086
    sh task.sh go build -o "$cmd_file" $task_go_files
  fi
  $cmd_file "$@"
)
