#!/bin/sh
set -o nounset -o errexit

test "${guard_8ca43ec+set}" = set && return 0; guard_8ca43ec=x

. "$(dirname "$0")"/task.sh

sub() (
  echo beec059 "$@" >&2
  verbose=false
  while getopts v OPT
  do
    case $OPT in
      v) verbose=true ;;
      \?) echo 54f8b81 >&2 ; return 1 ;;
      *) return 1 ;;
    esac
  done
  shift $((OPTIND - 1))
  unset OPTIND

  for arg in "$@"
  do
    if $verbose
    then
      echo "sub: $arg" >&2
    fi
    echo "$arg"
  done
)

super() {
  verbose=false
  while getopts v OPT
  do
    case $OPT in
      v) verbose=true ;;
      *) return 1 ;;
    esac
  done
  # unset OPTIND before calling next `getopts`
  shift $((OPTIND - 1))
  unset OPTIND

  set_ifs_newline
  # shellcheck disable=SC2046
  set -- $(sub "$@")
  restore_ifs
  for arg in "$@"
  do
    echo "cp: $arg"
  done
}

super -v -- -v -- -f "ABC XYZ" "123 456"
