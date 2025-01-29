#!/bin/sh
test "${guard_ad319a9+set}" = set && return 0; guard_ad319a9=x

. ./task-bun.lib.sh

subcmd_test() {
  subcmd_bun test "$@"
}
