#!/bin/sh
set -o nounset -o errexit

test "${guard_5c3f500+set}" = set && return 0; guard_5c3f500=-

. task.sh

subcmd_json2sh() ( # Convert JSON to shell script.
  cd "$script_dir_path" || exit 1
  subcmd_volta run node json2sh.mjs "$@"
)
