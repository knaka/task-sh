# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_976e8b5-false}" && return 0; sourced_976e8b5=true

# React Router (formerly Remix) https://reactrouter.com/

. ./task.sh
. ./node.lib.sh

rr_project_dir_3376d5a="$PROJECT_DIR"

set_rr_project_dir() {
  rr_project_dir_3376d5a="$1"
}

react_router() {
  run_node_modules_bin .bin/react-router "$@"
}

# Run `react-router`.
subcmd_rr() {
  react_router "$@"
}

alias react-router=react_router

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
