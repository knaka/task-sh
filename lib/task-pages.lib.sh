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

: "${pages_functions_src_pattern:=./src/functions/**/*.ts}"

set_pages_functions_src_pattern() {
  pages_functions_src_pattern="$1"
}

: "${pages_functions_dir_path:=./functions}"

set_pages_functions_dir_path() {
  pages_functions_dir_path="$1"
}

# shellcheck disable=SC2120
task_pages__functions__build() { # Build the Functions files into a JS file.
  rm -fr "$pages_functions_dir_path"
  if test -n "$pages_functions_src_pattern"
  then
    set -- "$@" "$pages_functions_src_pattern"
  fi
  # `--platform=node` is required to use the Node.js built-in modules even for `require()`.
  subcmd_esbuild --platform=node --bundle --format=esm --outdir="$pages_functions_dir_path" "$@"
}

task_pages__functions__watchbuild() { # Watch the functions files and build them into JS files.
  # Specify "forever" to keep the process running even after the stdin is closed.
  task_pages__functions__build --invocation-mode=exec --watch=forever
}

# --------------------------------------------------------------------------
# Deployment
# --------------------------------------------------------------------------

pages_routes_json_path_6c18f24="./pages_routes.json"

set_pages_routes_json_path() {
  pages_routes_json_path_6c18f24="$1"
}

. ./task-yq.lib.sh

get_pages_output_dir() {
  memoize bf05cb9 subcmd_yq --exit-status eval '.pages_build_output_dir' wrangler.toml
}

task_put_pages_routes_json() { # Put the routes JSON file.
  if test -r "$pages_routes_json_path_6c18f24"
  then
    cp -f "$pages_routes_json_path_6c18f24" "$(get_pages_output_dir)"/_routes.json
  fi
}

task_pages__deploy() { # Deploy the project.
  task_put_pages_routes_json
  subcmd_wrangler pages deploy
}

get_pages_build_output_dir() {
  memoize 96811e6 subcmd_yq --exit-status eval '.pages_build_output_dir' wrangler.toml
}
