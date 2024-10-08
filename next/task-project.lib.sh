#!/bin/sh
set -o nounset -o errexit

test "${guard_0047173+set}" = set && return 0; guard_0047173=x

. task.sh
. task-volta.lib.sh
. task-next.lib.sh

usage_next_prompt() {
  echo
  echo "[b] Open a Browser"
  echo "[c] Clear console"
  echo "[x] to exit"
}

next_prompt() {
  usage_next_prompt
  while true
  do
    case "$(get_key)" in
      b) open_browser "$1" ;;
      c) clear ;;
      x) break ;;
      *) usage_next_prompt ;;
    esac
  done
}

task_dev() { # Development server for Next.js
  chdir_script
  load_env
  if test "${PORT+set}" = set
  then
    export PORT
  fi
  # shellcheck disable=SC2317
  "$(npx_cmd_path)" next dev 2>&1 | tee "$(temp_dir_path)"/next-dev.log &
  while true
  do
    sleep 1
    if grep -q "Ready in " "$(temp_dir_path)"/next-dev.log > /dev/null 2>&1
    then
      break
    fi
  done
  next_prompt "http://localhost:${PORT:-3000}"
  chdir_original
}

task_build() { # Build the Next.js app.
  subcmd_npm run build
}

task_depbuild() ( # Build the Next.js app if the source is newer than the build.
  chdir_script
  if newer app --than .next
  then
    task_build
  fi
)

task_start() ( # Start the Next.js server with the production build.
  chdir_script
  load_env
  if test "${PORT+set}" = set
  then
    export PORT
  fi
  task_depbuild
  "$(npx_cmd_path next)" run start &
  next_prompt "http://localhost:${PORT:-3000}"
)
