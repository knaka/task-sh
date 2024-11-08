#!/bin/sh
set -o nounset -o errexit

test "${guard_a8ac234+set}" = set && return 0; guard_a8ac234=x

. ./task.sh

usage_prompt() {
  echo
  menu_item "&Clear"
  menu_item "E&xit"
}

prompt() {
  usage_prompt
  while true
  do
    case "$(get_key)" in
      c) clear ;;
      x) break ;;
      *) ;;
    esac
  done
}

cli_usage() {
  echo "exit: Exit the program."
}

task_cli() {
  while true
  do
    printf "> "
    IFS= read -r line
    case "$line" in
      (exit) break ;;
      ("") cli_usage ;;
      (*)
        backup_shell_flags
        set +o errexit
        eval "$line"
        echo "exit status: $?" >&2
        restore_shell_flags
        ;;
    esac
  done
}
