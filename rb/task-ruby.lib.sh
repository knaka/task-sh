#!/bin/sh
set -o nounset -o errexit

subcmd_irb() { # Launches an interactive Ruby shell.
  exec "$(dirname "$0")"/rb-cmds run irb "$@"
}
