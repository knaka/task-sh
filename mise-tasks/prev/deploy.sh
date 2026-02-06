#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_09166ed-false}" && return 0; sourced_09166ed=true

#MISE description="Deploy preview environment."

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" || exit 1; fi
. .lib/boot.lib.sh
before_source .lib

after_source
cd "$1" || exit 1; shift 2

echo Deploy preview environment.
