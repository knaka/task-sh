#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_09166ed-false}" && return 0; sourced_09166ed=true

#MISE description="Deploy preview environment."

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" || exit 1; fi
. .lib/min.lib.sh
before_source .lib
. .lib/utils.lib.sh
after_source
cd "$1" || exit 1; shift 2

echo Deploy preview environment.
