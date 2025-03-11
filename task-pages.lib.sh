# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_6b40fea-}" = true && return 0; sourced_6b40fea=true

. ./task.sh
. ./task-node.lib.sh

# subcmd_esbuild() { # Run the esbuild, the JavaScript bundler command.ss
#   run_node_modules_bin esbuild bin/esbuild "$@"
# }

# subcmd_esbuild() {
#     cat <<EOF | subcmd_node --input-type=module
# import esbuild from "esbuild";
# import { wasmLoader } from 'esbuild-plugin-wasm'

# esbuild.build({
#   entryPoints: ["./src-pages/functions/api/add.ts"],
#   bundle: true,
#   outfile: "./functions/api/add.js",
#   platform: "neutral",
#   format: "esm",
#   plugins: [
#     wasmLoader(),
#   ],
#   external: ["wasi_snapshot_preview1"],
# }).catch(() => process.exit(1));
# EOF
# }

subcmd_wrangler() { # Run the Cloudflare Wrangler command.
  run_node_modules_bin wrangler bin/wrangler.js "$@"
}

: "${wrangler_toml_path:=$PROJECT_DIR/wrangler.toml}"

# # --------------------------------------------------------------------------
# # Cloudflare Pages Functions.
# # --------------------------------------------------------------------------

# : "${pages_functions_src_pattern:="$PROJECT_DIR/src/functions/**/*.ts"}"

# set_pages_functions_src_pattern() {
#   pages_functions_src_pattern="$1"
# }

# : "${pages_functions_dir_path:="$PROJECT_DIR"/functions}"

# set_pages_functions_dir_path() {
#   pages_functions_dir_path="$1"
# }

# # shellcheck disable=SC2120
# task_pages__functions__build() { # Build the Functions files into a JS file.
#   rm -fr "$pages_functions_dir_path"
#   if test -n "$pages_functions_src_pattern"
#   then
#     set -- "$@" "$pages_functions_src_pattern"
#   fi
#   # `--platform=node` is required to use the Node.js built-in modules even for `require()`.
#   subcmd_esbuild --platform=node --bundle --format=esm --outdir="$pages_functions_dir_path" "$@"
# }

# task_pages__functions__watchbuild() { # Watch the functions files and build them into JS files.
#   # Specify "--watch=forever" to keep the process running even after the stdin is closed.
#   task_pages__functions__build --watch=forever "$@"
# }

# --------------------------------------------------------------------------
# Deployment
# --------------------------------------------------------------------------

pages_routes_json_path_6c18f24="./pages_routes.json"

set_pages_routes_json_path() {
  pages_routes_json_path_6c18f24="$1"
}

. ./task-yq.lib.sh

pages_build_output_dir() {
  memoize subcmd_yq --exit-status eval '.pages_build_output_dir' "$wrangler_toml_path"
}

task_pages__routes_json__put() { # Put the routes JSON file.
  if test -r "$pages_routes_json_path_6c18f24" && ! cmp -s "$pages_routes_json_path_6c18f24" "$(pages_build_output_dir)"/_routes.json >/dev/null 2>&1
  then
    cp -f "$pages_routes_json_path_6c18f24" "$(pages_build_output_dir)"/_routes.json
  fi
}

pages_deploy() {
  task_pages__routes_json__put
  subcmd_wrangler pages deploy "$@"
}

task_pages__prod__deploy() { # Deploy the project to the production environment.
  pages_deploy
}

task_pages__prev__deploy() { # Deploy the project to the preview environment.
  pages_deploy --branch preview
}

get_pages_build_output_dir() {
  memoize subcmd_yq --exit-status eval '.pages_build_output_dir' "$wrangler_toml_path"
}

pages_secret_put() {
  subcmd_wrangler pages secret put "$@"
}

subcmd_pages__prod__secret__put() { # [key] Put the secret to the Cloudflare Pages.
  pages_secret_put --env production "$@"
}

subcmd_pages__prev__secret__put() { # [key] Put the secret to the Cloudflare Pages preview environment.
  pages_secret_put --env preview "$@"
}

subcmd_pages__project_name() {
  memoize subcmd_yq --exit-status eval ".name" "$wrangler_toml_path"
}

pages_tail() { # Tail the log of the deployment.
  subcmd_wrangler pages deployment tail --project-name "$(subcmd_pages__project_name)"
}

subcmd_pages__prod__tail() { # Tail the log of the production deployment.
  pages_tail --environment production
}

subcmd_pages__prev__tail() { # Tail the log of the preview deployment.
  pages_tail --environment preview
}
