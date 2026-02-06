# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_09e19ca-false}" && return 0; sourced_09e19ca=true

type before_source >/dev/null 2>&1 || . ./boot.lib.sh
before_source .
. ./utils.lib.sh
after_source

cd "$1" || exit 1; shift 2
