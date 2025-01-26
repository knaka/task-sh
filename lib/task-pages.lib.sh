#!/bin/sh
# shellcheck disable=SC3043
test "${guard_82d2bd6+set}" = set && return 0; guard_82d2bd6=x
set -o nounset -o errexit

. ./task.sh
. ./task-node.lib.sh

subcmd_esbuild() { # Run the esbuild, the JavaScript bundler command.ss
  run_node_modules_bin esbuild bin/esbuild "$@"
}

subcmd_wrangler() { # Run the Cloudflare Wrangler command.
  run_node_modules_bin wrangler bin/wrangler.js "$@"
}

# --------------------------------------------------------------------------
# Cloudflare Pages Functions.
# --------------------------------------------------------------------------

pages_functions_src_dir_path="./src/functions"
pages_functions_dir_path="./functions"

# shellcheck disable=SC2120
task_functions__build() { # Build the Functions files into a JS file.
  rm -fr "$pages_functions_dir_path"
  push_ifs
  ifs_newline
  subcmd_esbuild --bundle --format=esm --outdir="$pages_functions_dir_path" "$@" "$pages_functions_src_dir_path/**/*.ts"
  pop_ifs
}

task_functions__watchbuild() { # Watch the functions files and build them into JS files.
  # Specify "forever" to keep the process running even after the stdin is closed.
  task_functions__build --watch=forever
}

# --------------------------------------------------------------------------
# Deployment
# --------------------------------------------------------------------------

task_deploy() { # Deploy the project.
  set_node_env
  subcmd_wrangler pages deploy
}
