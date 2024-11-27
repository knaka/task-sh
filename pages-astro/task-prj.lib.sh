#!/bin/sh
# shellcheck disable=SC3043
test "${guard_fb8b13a+set}" = set && return 0; guard_fb8b13a=x
set -o nounset -o errexit

. ./task.sh
. ./task-volta.lib.sh

subcmd_astro() {
  set_node_env
  cross_run node node_modules/.bin/astro "$@"
}

task_astro__build() {
  subcmd_astro build
}

task_astro__dev() {
  host=127.0.0.1
  port=4321
  sh task.sh subcmd_astro dev --host "$host" --port "$port" 2>&1 | tee "$(temp_dir_path)"/astro-dev.log &
  while true
  do
    sleep 1
    if grep -q "watching for file changes" "$(temp_dir_path)"/astro-dev.log > /dev/null 2>&1
    then
      break
    fi
  done
  while true
  do
    menu \
      "Open a &browser" \
      "&Clear console" \
      "Bui&ld" \
      "E&xit"
    case "$(get_key)" in
      (b) open_browser "http://$host:$port" ;;
      (c) clear ;;
      (l) task_astro__build ;;
      (x) break ;;
      (*) ;;
    esac
  done
}
