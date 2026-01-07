# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_73228fa-false}" && return 0; sourced_73228fa=true

. ./node.lib.sh

: "${astro_project_dir_0135e32:=$PROJECT_DIR}"

set_astro_project_dir() {
  astro_project_dir_0135e32="$1"
}

astro_project_dir() {
  echo "$astro_project_dir_0135e32"
}

astro() {
  run_node_modules_bin astro/astro.js --root "$astro_project_dir_0135e32" "$@"
}

# Execute Astro command
subcmd_astro() {
  astro "$@"
}

# Build Astro application
task_astro__build() {
  astro --root "$astro_project_dir_0135e32" build "$@"
}
