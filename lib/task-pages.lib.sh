#!/bin/sh
# shellcheck disable=SC3043
test "${guard_82d2bd6+set}" = set && return 0; guard_82d2bd6=x
set -o nounset -o errexit

. ./task.sh
. ./task-volta.lib.sh

subcmd_esbuild() { # Run the esbuild, the JavaScript bundler command.ss
  node_modules_run_bin esbuild bin/esbuild "$@"
}

subcmd_wrangler() { # Run the Cloudflare Wrangler command.
  node_modules_run_bin wrangler bin/wrangler.js "$@"
}

# --------------------------------------------------------------------------
# Cloudflare Workers codes.
# --------------------------------------------------------------------------

functions_src_dir="functions-src"
functions_dir="functions"

# shellcheck disable=SC2120
task_worker__build() { # Build the worker files into a JS file.
  rm -fr "$functions_dir"
  push_ifs
  ifs_newline
  # shellcheck disable=SC2046
  # subcmd_esbuild --bundle --format=esm --outdir="$functions_dir" $(find "$functions_src_dir" -type f -name "*.ts" -o -name "*.tsx") "$@"
  subcmd_esbuild --bundle --format=esm --outdir="$functions_dir" "$@" "$functions_src_dir/**/*.ts"
  pop_ifs
}

task_worker__depbuild() { # Build the worker files if the source files are newer than the output files.
  if newer "$functions_src_dir" --than "$functions_dir"
  then
    task_worker__build
  fi
}

task_worker__watchbuild() { # Watch the worker files and build them into JS files.
  # "forever" to keep the process running even after the stdin is closed.
  task_worker__build --watch=forever
}

# --------------------------------------------------------------------------
# Deployment
# --------------------------------------------------------------------------

task_deploy() { # Deploy the project.
  set_node_env
  subcmd_wrangler pages deploy
}
