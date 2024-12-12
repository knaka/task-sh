#!/bin/sh
set -o nounset -o errexit

pwd_cbe7ee2="$(pwd)"
cd "$(dirname "$0")"
. ./task.sh
cd "$pwd_cbe7ee2"

blocks=false

while getopts "bt:" opt
do
  case "$opt" in
    b) blocks=true;;
    *) exit 1;;
  esac
done
shift $((OPTIND-1))
unset OPTIND

if test "$ARG0BASE" = "edw"
then
  blocks=true
fi

if which code > /dev/null
then
  opts=
  if $blocks
  then
    opts="--wait $opts"
  fi
  for arg in "$@"
  do
    if ! test -e "$arg"
    then
      printf "%s does not exist. Create? (y/N): " "$arg"
      read -r yn
      case "$yn" in
        [yY]*) ;;
        *) exit 0 ;;
      esac
      touch "$arg"
    elif test -d "$arg"
    then
      printf "%s is a directory. Open? (y/N): " "$arg"
      yn="$(get_key)"
      echo "$yn"
      case "$yn" in
        [yY]*) ;;
        *) exit 0 ;;
      esac
    fi
  done
  # shellcheck disable=SC2086
  exec code $opts "$@"
fi
