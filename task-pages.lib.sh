# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_6b40fea-}" = true && return 0; sourced_6b40fea=true

. ./task.sh
. ./task-node.lib.sh

: "${pages_wrangler_toml_path_b0f864e:=$PROJECT_DIR/wrangler.toml}"

set_pages_wrangler_toml_path() {
  pages_wrangler_toml_path_b0f864e="$1"
}

: "${pages_routes_json_path_6c18f24:=$PROJECT_DIR/pages_routes.json}"

set_pages_routes_json_path() {
  pages_routes_json_path_6c18f24="$1"
}

: "${pages_project_path:=$PROJECT_DIR}"

set_pages_project_path() {
  pages_project_path="$1"
  set_pages_wrangler_toml_path "$1/wrangler.toml"
  set_pages_routes_json_path "$1/pages_routes.json"
}

subcmd_pages__wrangler() { # Run the Cloudflare Wrangler command.
  # “ERROR Pages does not support custom paths for the `wrangler.toml` configuration file”, that's why we need to change the directory.
  push_dir "$pages_project_path"
  run_node_modules_bin wrangler bin/wrangler.js "$@"
  pop_dir
}

# --------------------------------------------------------------------------
# Deployment
# --------------------------------------------------------------------------

. ./task-yq.lib.sh

pages_build_output_dir() {
  memoize subcmd_yq --exit-status eval '.pages_build_output_dir' "$pages_wrangler_toml_path_b0f864e"
}

task_pages__routes_json__put() { # Put the routes JSON file.
  if test -r "$pages_routes_json_path_6c18f24" && ! cmp -s "$pages_routes_json_path_6c18f24" "$(pages_build_output_dir)"/_routes.json >/dev/null 2>&1
  then
    cp -f "$pages_routes_json_path_6c18f24" "$(pages_build_output_dir)"/_routes.json
  fi
}

pages_deploy() {
  task_pages__routes_json__put
  subcmd_pages__wrangler pages deploy "$@"
}

task_pages__prod__deploy() { # Deploy the project to the production environment.
  pages_deploy
}

task_pages__prev__deploy() { # Deploy the project to the preview environment.
  pages_deploy --branch preview
}

get_pages_build_output_dir() {
  memoize subcmd_yq --exit-status eval '.pages_build_output_dir' "$pages_wrangler_toml_path_b0f864e"
}

pages_secret_put() {
  subcmd_pages__wrangler pages secret put "$@"
}

subcmd_pages__prod__secret__put() { # [key] Put the secret to the Cloudflare Pages.
  pages_secret_put --env production "$@"
}

subcmd_pages__prev__secret__put() { # [key] Put the secret to the Cloudflare Pages preview environment.
  pages_secret_put --env preview "$@"
}

subcmd_pages__project_name() {
  memoize subcmd_yq --exit-status eval ".name" "$pages_wrangler_toml_path_b0f864e"
}

pages_tail() { # Tail the log of the deployment.
  subcmd_pages__wrangler pages deployment tail --project-name "$(subcmd_pages__project_name)"
}

subcmd_pages__prod__tail() { # Tail the log of the production deployment.
  pages_tail --environment production
}

subcmd_pages__prev__tail() { # Tail the log of the preview deployment.
  pages_tail --environment preview
}
