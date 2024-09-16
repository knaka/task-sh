#!/bin/sh
set -o nounset -o errexit

# stack: The Haskell Tool Stack https://hackage.haskell.org/package/stack
ver=3.1.1

cmd_path="$HOME"/.ghcup/bin/stack-"$ver"
if ! test -x "$cmd_path"
then
  sh "$(dirname "$0")"/ghcup-cmd.sh install stack "$ver"
fi
exec "$cmd_path" "$@"
