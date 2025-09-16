# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_976e8b5-false}" && return 0; sourced_976e8b5=true

# React Router (formerly Remix) https://reactrouter.com/

. ./task.sh
. ./node.lib.sh

react_router() {
  run_node_modules_bin .bin/react-router "$@"
}

alias react-router=react_router

# Run `react-router`.
subcmd_rr() {
  react_router "$@"
}

alias subcmd_react-router=subcmd_rr
