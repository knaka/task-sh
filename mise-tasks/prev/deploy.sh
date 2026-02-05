#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_733f195-false}" && return 0; sourced_926c572=true

#MISE description="Deploy preview environment."

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./.foo.sh
. ../.bar.sh
cd "$1" || exit 1; shift 2

echo Deploy preview environment.
