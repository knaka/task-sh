#!/bin/sh
set -o nounset -o errexit

cmd_name=$(basename "$0")
should_block=false
if test "$cmd_name" = "edw"
then
  should_block=true
fi
if which code > /dev/null
then
  opts=
  if "$should_block"
  then
    opts="--wait $opts"
  fi
  arg="$1"
  if test -d "$arg"
  then
    printf "%s is a directory. Open? (y/N): " arg
    read -r yn
    case "$yn" in
      [yY]*) ;;
      *) exit 0 ;;
    esac
  fi
  exec code "$@"
fi
