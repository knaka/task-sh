# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_9da69a1-false}" && return 0; sourced_9da69a1=true

. ./task.sh

: "${remix_project_dir_b4b3371:=$PROJECT_DIR}"

set_remix_project_dir() {
  remix_project_dir_b4b3371="$1"
}

subcmd_remix() { # Run remix.
  run_node_modules_bin @remix-run/dev dist/cli.js "$@" "$remix_project_dir_b4b3371"
}

task_remix__build() { # Build
  subcmd_remix vite:build
}

task_remix__dev() { # Start development server
  load_env
  local host="${REMIX_DEV_HOST:-127.0.0.1}"
  local port="${REMIX_DEV_PORT:-3000}"
  set -- "$@" --host "$host"
  set -- "$@" --port "$port"
  subcmd_remix vite:dev "$@"
}
