#!/bin/sh
set -o nounset -o errexit

cmd=ghq

if test "${1+SET}" = "SET"
then
  case "$1" in
    st|stat)
      exec "$cmd" root
      ;;
    *)
      exec $cmd "$@"
      ;;
  esac
fi

# If not subcommand is specified, list repositories.
repo=$("$cmd" list | peco)
if test -z "${repo}"
then
  exit 1
fi
echo "$("$cmd" root)"/"${repo}"
