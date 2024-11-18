#!/bin/sh
set -o nounset -o errexit

test "${guard_a8ac234+set}" = set && return 0; guard_a8ac234=x

. ./task.sh
. ./task-docker.lib.sh

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

subcmd_docker__run() { # Run a command in a Docker container.
  task_docker__start__temp
  subcmd_docker run --rm -it -v "$(pwd):/work" "$(subcmd_docker build --quiet --file test.Dockerfile .)" "$@"
}

task_docker__test() { # Run tests in a Docker container.
  subcmd_docker__run ./task test
}
