#!/bin/sh
set -o nounset -o errexit

test "${guard_972a0be+set}" = set && return 0; guard_972a0be=x

. task-volta.lib.sh

mkdir -p .next .vercel out
set_sync_ignored .next .vercel out

set_sync_ignored next-env.d.ts || :

subcmd_next() {
  set_node_env
  node"$(exe_ext)" node_modules/next/dist/bin/next "$@"
}
