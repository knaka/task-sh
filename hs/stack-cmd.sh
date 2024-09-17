#!/bin/sh
set -o nounset -o errexit

# stack: The Haskell Tool Stack https://hackage.haskell.org/package/stack
ver=3.1.1

if ! sh "$(dirname "$0")"/ghcup-cmd.sh whereis stack "$ver" > /dev/null 2>&1
then
  sh "$(dirname "$0")"/ghcup-cmd.sh install stack "$ver"
fi
cmd_path="$(sh "$(dirname "$0")"/ghcup-cmd.sh whereis stack "$ver")"
exec "$cmd_path" "$@"
