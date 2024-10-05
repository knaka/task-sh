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
      echo "Removed temp dir." >&2
    fi
  }
  trap cleanup_0968807 EXIT
  "$npm_cmd_path" run dev 2>&1 | tee "$temp_dir_path"/next-dev.log &
  while true
  do
    sleep 1
    if grep -q "Ready in " "$temp_dir_path"/next-dev.log > /dev/null 2>&1
    then
      break
    fi
  done
  while true
  do
    cmd="$(prompt "Command")"
    case "$cmd" in
      "")
        echo "exit | url" >&2
        ;;
      url)
        # open_browser "http://localhost:${PORT:-3000}"
        echo "http://localhost:${PORT:-3000}" >&2
        ;;
      exit)
        break
        ;;
      *)
        echo Unknown command: "$cmd" >&2
        ;;
    esac
  done
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
