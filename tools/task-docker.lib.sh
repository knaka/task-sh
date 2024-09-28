#!/bin/sh
set -o nounset -o errexit

test "${guard_3b8c583+set}" = set && return 0; guard_3b8c583=-

. task.sh

subcmd_docker() (
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
