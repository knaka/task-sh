#!/bin/sh
test "${guard_5dd52f9+set}" = set && return 0; guard_5dd52f9=x
set -o nounset -o errexit

subcmd_gsed() {
  run_pkg_cmd \
    --cmd=gsed \
    --brew-id=gnu-sed \
    -- "$@"
}
