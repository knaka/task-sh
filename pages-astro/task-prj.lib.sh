#!/bin/sh
# shellcheck disable=SC3043
test "${guard_fb8b13a+set}" = set && return 0; guard_fb8b13a=x
set -o nounset -o errexit

. ./task.sh
. ./task-volta.lib.sh

# --------------------------------------------------------------------------
# Commands.
# --------------------------------------------------------------------------

subcmd_wrangler() { # Run the Cloudflare Wrangler command.
  node_moduels_run_bin wrangler bin/wrangler.js "$@"
}

subcmd_esbuild() { # Run the esbuild, the JavaScript bundler command.ss
  node_moduels_run_bin esbuild bin/esbuild "$@"
}

subcmd_tsc() { # Run the TypeScript compiler command.
  node_moduels_run_bin typescript bin/tsc "$@"
}

subcmd_astro() { # Run the Astro command.
  node_moduels_run_bin astro astro.js "$@"
}

task_astro__build() {
  subcmd_astro build
}

# --------------------------------------------------------------------------
# Cloudflare Workers codes.
# --------------------------------------------------------------------------

functions_src_dir="functions-src"
functions_dest_dir="functions"

# shellcheck disable=SC2120
task_worker__build() { # Build the worker files into a JS file.
  rm -fr "$functions_dest_dir"
  push_ifs
  ifs_newline
  # shellcheck disable=SC2046
  subcmd_esbuild --bundle --format=esm --outdir="$functions_dest_dir" $(find "$functions_src_dir" -type f -name "*.ts" -o -name "*.tsx") "$@"
  pop_ifs
}

task_worker__depbuild() { # Build the worker files if the source files are newer than the output files.
  if newer "$functions_src_dir" --than "$functions_dest_dir"
  then
    task_worker__build
  fi
}

# --------------------------------------------------------------------------
# Development
# --------------------------------------------------------------------------

task_worker__watchbuild() { # Watch the worker files and build them into JS files.
  # "forever" to keep the process running even after the stdin is closed.
  task_worker__build --watch=forever
}

task_pages__dev() { # Launch the Wrangler Pages development server.
  NODE_ENV=development
  APP_ENV="$NODE_ENV"
  export APP_ENV NODE_ENV
  load_env
  sh task.sh task_worker__watchbuild &
  if test "${PAGES_DEV_PORT+set}" = set
  then
    set -- "$@" --port "$PAGES_DEV_PORT"
  fi
  if test "${ASTRO_DEV_PORT+set}" = set
  then
    set -- "$@" --binding AP_DEV_PORT="$ASTRO_DEV_PORT"
  fi
  subcmd_wrangler pages dev "$@" --live-reload ./dist
}

task_astro__dev() {
  NODE_ENV=development
  APP_ENV="$NODE_ENV"
  export APP_ENV NODE_ENV
  load_env
  local host=127.0.0.1
  local port=4321
  if test "${ASTRO_DEV_PORT+set}" = set
  then
    port="$ASTRO_DEV_PORT"
  fi
  if test "${PAGES_DEV_PORT+set}" = set
  then
    API_DEV_PORT="$PAGES_DEV_PORT"
    export API_DEV_PORT
  fi
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
