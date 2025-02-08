#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_42cc02b-}" = true && return 0; sourced_42cc02b=true
set -o nounset -o errexit

invoke() {
  local invocation_mode=standard
  local arg
  for arg in "$@"
  do
    case "$arg" in
      (--invocation=*) invocation_mode=${arg#--invocation=};;
      (*) set -- "$@" "$arg";;
    esac
    shift
  done
  if test $# -eq 0
  then
    echo "No command specified" >&2
    exit 1
  fi
  case "$1" in
    (*/*)
      if ! test -x "$1"
      then
        echo "Command not found: $1" >&2
        exit 1
      fi
      ;;
    (*)
      if ! command -v "$1" >/dev/null
      then
        echo "Command not found: $1" >&2
        exit 1
      fi
      ;;
  esac
  case "$invocation_mode" in
    (exec) exec "$@";;
    (background) "$@" &;;
    (standard) "$@";;
  esac
}

# Usage:

invoke date --invocation=background "$@" 2>&1
echo 07260c5
wait
echo b0a790d

invoke --invocation=standard date "$@" 2>&1
echo c4d75e2
wait
echo cd455b4

invoke --invocation=exec date "$@" 2>&1
echo db9cf4c
wait
echo d11ee57
