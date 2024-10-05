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
  for i_519fa93 in $(seq 1 "$(jobs 2>&1 | wc -l)")
  do
    kill "%$i_519fa93" > /dev/null 2>&1
    wait "%$i_519fa93" > /dev/null 2>&1 || :
  done
  while true
  do
    sleep 1
    # On some systems, `kill` cannot detect the process if `jobs` is not called before it.
    if test -z "$(jobs 2>&1 | grep -v Terminated)"
    then
      break
    fi
  done
}

prompt_exit() (
  while true
  do
    printf 'Enter "exit" to exit: '
    read -r input
    # jobs
    if [ "$input" = "exit" ]
    then
      break
    fi
  done
)

subcmd_dev() (
  chdir_script
  load_env
  if test "${PORT+set}" = set
  then
    export PORT
  fi
  # Create direct child to kill the process.
  npm_cmd_path="$(subcmd_volta which npm)"
  temp_dir_path="$(mktemp -d)"
  cleanup_0968807() {
    # shellcheck disable=SC2317
    if test -n "${temp_dir_path+set}"
    then
      rm -rf "$temp_dir_path"
    fi
  }
  trap cleanup_0968807 EXIT
  "$npm_cmd_path" run dev > "$temp_dir_path"/next-dev.log 2>&1 &
  tail -f "$temp_dir_path"/next-dev.log 2> /dev/null &
  while true
  do
    if grep -q "Ready" "$temp_dir_path"/next-dev.log > /dev/null 2>&1
    # if grep -q "Compiled" "$temp_dir_path"/next-dev.log > /dev/null 2>&1
    then
      break
    fi
    sleep 1
  done
  open_browser "http://localhost:${PORT:-3000}"
  prompt_exit
  kill_children
)

subcmd_build() (
  subcmd_npm run build
)

subcmd_depbuild() (
  chdir_script
  if newer app --than .next
  then
    subcmd_build
  fi
)

subcmd_start() {
  chdir_script
  load_env
  if test "${PORT+set}" = set
  then
    export PORT
  fi
  subcmd_depbuild
  npm_cmd_path="$(subcmd_volta which npm)"
  "$npm_cmd_path" run start &
  open_browser "http://localhost:${PORT:-3000}"
  prompt_exit
  kill_children
}
