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

subcmd_next() {
  subcmd_npx next "$@"
}

subcmd_dev() (
  chdir_script
  load_env
  if test "${PORT+set}" = set
  then
    export PORT
  fi
  temp_dir_path="$(mktemp -d)"
  cleanup_0968807() {
    # shellcheck disable=SC2317
    if test -n "${temp_dir_path+set}"
    then
      rm -rf "$temp_dir_path"
      echo "Removed temp dir." >&2
    fi
  }
  # trap cleanup_0968807 EXIT
  push_cleanup cleanup_0968807
  # subcmd_npm run dev 2>&1 | tee "$temp_dir_path"/next-dev.log &
  # subcmd_next dev 2>&1 | tee "$temp_dir_path"/next-dev.log &
  # sh task.sh next dev 2>&1 | tee "$temp_dir_path"/next-dev.log &
  npx_path="$(subcmd_volta which npx)"
  "$npx_path" next dev 2>&1 | tee "$temp_dir_path"/next-dev.log &
  push_cleanup kill_children
  while true
  do
    sleep 1
    if grep -q "Ready in " "$temp_dir_path"/next-dev.log > /dev/null 2>&1
    then
      break
    fi
  done
  usage_8e51f1d() {
    echo "[b] Open a Browser"
    echo "[c] Clear console"
    echo "[x] to exit"
  }
  usage_8e51f1d
  # Some "/bin/sh" provides `-s` option.
  # shellcheck disable=SC3045
  while read -rsn1 key
  do
    case "$key" in
      b) open_browser "http://localhost:${PORT:-3000}" ;;
      c) clear ;;
      x) break ;;
      *) usage_8e51f1d ;;
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
