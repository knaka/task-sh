#!/bin/sh
set -o nounset -o errexit

test "${guard_0047173+set}" = set && return 0; guard_0047173=x

. task.sh
. task-volta.lib.sh

mkdir -p .next .vercel
set_sync_ignored .next .vercel

set_sync_ignored next-env.d.ts || :

open_browser() (
  case "$(uname -s)" in
    Linux)
      xdg-open "$1" ;;
    Darwin)
      open "$1" ;;
    Windows_NT)
      start "$1" ;;
    *)
      echo "Unsupported OS: $(uname -s)" >&2
      exit 1
      ;;
  esac
)

kill_children() {
  while true
  do
    # On some systems, `kill` cannot detect the process if `jobs` is not called before it.
    if test -z "$(jobs 2>&1 | grep -v Terminated)"
    then
      break
    fi
    if ! kill %% > /dev/null 2>&1
    then
      break
    fi
  done
}

prompt_exit() {
  while true
  do
    printf 'Enter "exit" to exit: '
    read -r input
    jobs
    if [ "$input" = "exit" ]
    then
      break
    fi
  done
}

subcmd_start() (
  chdir_script
  load_env
  if test "${PORT+set}" = set
  then
    export PORT
  fi
  # Create direct child to kill the process.
  npm_cmd_path="$(subcmd_volta which npm)"
  "$npm_cmd_path" run dev &
  open_browser "http://localhost:${PORT:-3000}"
  prompt_exit
  kill_children
)

subcmd_build() (
  subcmd_npm run build
)
