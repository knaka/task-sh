#!/bin/sh
set -o nounset -o errexit

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
exec docker "$@"
