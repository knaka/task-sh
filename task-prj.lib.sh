#!/bin/sh
set -o nounset -o errexit

test "${guard_a8ac234+set}" = set && return 0; guard_a8ac234=x

. ./task.sh

repl_usage() {
  echo "exit: Exit the program."
}

task_repl() { # Start a REPL.
  while true
  do
    printf "> "
    IFS= read -r line
    case "$line" in
      (exit) break;;
      ("") repl_usage;;
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

subcmd_exec() { # Execute a command in task.sh context.
  backup_shell_flags
  set +o errexit
  "$@"
  echo "Exit status: $?" >&2
  restore_shell_flags
}
