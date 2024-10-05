#!/bin/sh
set -o nounset -o errexit

test "${guard_0047173+set}" = set && return 0; guard_0047173=x

. task.sh

mkdir -p .next .vercel
set_sync_ignored .next .vercel

set_sync_ignored next-env.d.ts || :

subcmd_start() (
  load_env
  if test "${PORT+set}" = set
  then
    export PORT
  fi
  subcmd_npm run dev 
)

subcmd_build() (
  subcmd_npm run build
)
