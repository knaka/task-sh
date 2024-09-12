#!/bin/sh

subcmd_run() { # Run JS script.
  original_wokrking_dir_path="$PWD"
  cd "$(dirname "$0")" || exit 1
  volta run node lib/run-node.mjs "$original_wokrking_dir_path" "$@"
}
