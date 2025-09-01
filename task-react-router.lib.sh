# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_9da69a1-false}" && return 0; sourced_9da69a1=true

# React Router (formerly Remix) https://reactrouter.com/

. ./task.sh
. ./task-node.lib.sh

rr_project_dir_3376d5a="$PROJECT_DIR"

set_rr_project_dir() {
  rr_project_dir_3376d5a="$1"
}

# Run `react-router`.
subcmd_rr() {
  run_node_modules_bin @react-router dev/bin.js "$@"
}

alias react-router=subcmd_rr

alias subcmd_react-router=subcmd_rr

# Build
task_rr__build() {
  react-router build "$rr_project_dir_3376d5a"
}

# List routes
task_rr__routes() {
  react-router routes "$rr_project_dir_3376d5a"
}

# Start development server
task_rr__dev() {
  load_env
  local host="${RR_DEV_HOST:-127.0.0.1}"
  local port="${RR_DEV_PORT:-3000}"
  set -- "$@" --host "$host"
  set -- "$@" --port "$port"
  react-router dev "$rr_project_dir_3376d5a" "$@"
}
