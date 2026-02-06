#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_bb669ac-false}" && return 0; sourced_bb669ac=true

#MISE description="prev:doit desc"

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" || exit 1; fi
. .lib/min.lib.sh
before_source .lib
. .lib/doit.lib.sh
after_source
cd "$1" || exit 1; shift 2

doit() {
  echo Doing it.
  doit_sub1
}

case "${0##*/}" in
  (doit.sh|doit)
    set -o nounset -o errexit
    doit "$@"
    ;;
esac
