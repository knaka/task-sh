#!/bin/sh
test "${guard_fbaba3d+set}" = set && return 0; guard_fbaba3d=x
set -o nounset -o errexit

. ./task-bun.lib.sh

test_bun() {
  subcmd_bun --help
}
