# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_6b40fea-}" = true && return 0; sourced_6b40fea=true

. ./task.sh
. ./task-node.lib.sh

subcmd_esbuild() { # Run the esbuild, the JavaScript bundler command.ss
  run_node_modules_bin esbuild bin/esbuild "$@"
}

subcmd_wrangler() { # Run the Cloudflare Wrangler command.
  run_node_modules_bin wrangler bin/wrangler.js "$@"
}

: "${wrangler_toml_path:=$SCRIPT_DIR/wrangler.toml}"

# --------------------------------------------------------------------------
# Cloudflare Pages Functions.
# --------------------------------------------------------------------------

: "${pages_functions_src_pattern:="$SCRIPT_DIR"/src/functions/**/*.ts}"

set_pages_functions_src_pattern() {
  pages_functions_src_pattern="$1"
}

: "${pages_functions_dir_path:="$SCRIPT_DIR"/functions}"

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
  # Specify "--watch=forever" to keep the process running even after the stdin is closed.
  task_pages__functions__build --watch=forever "$@"
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

subcmd_pages__secret__put() {
  local key
  key="${1:-}"
  if test -z "$key"
  then
    key="$(prompt "Enter the secret name")"
  fi
  subcmd_wrangler pages secret put "$key"
}

subcmd_pages__name() {
  subcmd_yq --exit-status eval ".name" "$wrangler_toml_path"
}

subcmd_pages__log__tail() { # Tail the log of the deployment.
  subcmd_wrangler pages deployment tail --project-name "$(subcmd_pages__name)"
}
