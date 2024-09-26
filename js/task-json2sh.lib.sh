#!/bin/sh
set -o nounset -o errexit

subcmd_json2sh() { # Convert JSON to shell script.
  cd "$(dirname "$)")" || exit 1
  subcmd_volta run node json2sh.mjs "$@"
}
