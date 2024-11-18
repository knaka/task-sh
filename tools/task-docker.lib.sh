#!/bin/sh
set -o nounset -o errexit

test "${guard_3b8c583+set}" = set && return 0; guard_3b8c583=-

. ./task.sh

subcmd_docker() ( # Run a Docker command.
  if ! type docker > /dev/null 2>&1
  then
    echo "Docker is not installed. Exiting." >&2
    exit 1
  fi
  if ! docker version > /dev/null 2>&1
  then
    echo "Docker is not availabe. Exiting." >&2
    exit 1
  fi
  docker "$@"
)

task_docker__status() { # Show the status of Docker.
  subcmd_docker info
}

task_docker__start() { # Start Docker.
  if task_docker__status >/dev/null 2>&1
  then
    echo "Docker is already running." >&2
    return 0
  fi
  echo "Docker is not running. Starting Docker." >&2
  if is_darwin
  then
    # open --background -a Docker
    open -a "Docker"
    while true
    do
      sleep 1
      if task_docker__status >/dev/null 2>&1
      then
        echo "Docker has started." >&2
        break
      fi
    done
  else
    echo "Not implemented."
    return 1
  fi
}

task_docker__start__temp() { # Start Docker temporarily. If Docker is already running, do nothing when the task runner exits.
  if task_docker__status >/dev/null 2>&1
  then
    echo "Docker is already running. Using the existing Docker." >&2
  else
    task_docker__start
    add_cleanup_handler task_docker__stop
  fi
}

task_docker__stop() { # Stop Docker.
  if ! task_docker__status >/dev/null 2>&1
  then
    echo "Docker is not running." >&2
    return 0
  fi
  echo "Docker is running. Stopping Docker." >&2
  if is_darwin
  then
    # osascript -e 'quit app "Docker"'
    # osascript -e 'quit app "Docker Desktop"'
    killall "Docker Desktop"
  else
    echo "Not implemented."
    return 1
  fi
}
