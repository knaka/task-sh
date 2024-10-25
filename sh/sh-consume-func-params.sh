#!/bin/sh
set -o nounset -o errexit

test "${guard_8ca43ec+set}" = set && return 0; guard_8ca43ec=x

. "$(dirname "$0")"/task.sh

sub() (
  verbose=false
  while getopts v OPT
  do
    case $OPT in
      v) verbose=true ;;
      *) return 1 ;;
    esac
  done
  shift $((OPTIND - 1))
  for arg in "$@"
  do
    if $verbose
    then
      echo "sub: $arg" >&2
    fi
    echo "$arg"
  done
)

set_ifs_newline() {
  IFS="$(printf '\n\r')"
}

unset_ifs() {
  unset IFS
}

super() {
  set_ifs_newline
  # shellcheck disable=SC2046
  set -- $(sub "$@")
  unset_ifs
  for arg in "$@"
  do
    echo "cp: $arg"
  done
}

super -v -- -f "ABC XYZ" "123 456"
