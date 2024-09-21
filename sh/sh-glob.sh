#!/bin/sh
set -o nounset -o errexit

for arg in "$@"
do
  # shellcheck disable=SC2086
  set -- "$@" $arg
  shift
done

for arg in "$@"
do
  echo "$arg"
done
