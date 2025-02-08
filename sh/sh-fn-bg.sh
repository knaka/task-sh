#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_dc2ecbc-}" = true && return 0; sourced_dc2ecbc=true
set -o nounset -o errexit

my_sleep() {
  local exec=false
  local background=false
  OPTIND=1; while getopts eb OPT
  do
    case "$OPT" in
      (e) exec=true;;
      (b) background=true;;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  set -- /bin/sleep "$@"

  if $exec
  then
    exec "$@"
  elif $background
  then
    "$@" &
  else
    "$@"
  fi
}

my_sleep "$@"

echo Waiting >&2
wait

echo Exiting >&2
