#!/bin/sh
# set -o nounset -o errexit

onInt() {
  echo "Caught SIGINT" >&2
}

onExit() {
  echo "Exiting" >&2
}

trap onExit EXIT
trap onInt INT

echo Entering sleep >&2

sleep 10000

echo Raised from sleep >&2

sleep 10000