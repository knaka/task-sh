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
  node_moduels_run_bin wrangler wrangler "$@"
}

subcmd_esbuild() { # Run the esbuild, the JavaScript bundler command.ss
  node_moduels_run_bin esbuild esbuild "$@"
}

subcmd_tsc() { # Run the TypeScript compiler command.
  node_moduels_run_bin typescript tsc "$@"
}

subcmd_astro() { # Run the Astro command.
  node_moduels_run_bin astro astro "$@"
}

task_astro__build() {
  subcmd_astro build
}

# --------------------------------------------------------------------------
# Cloudflare Workers codes.
# --------------------------------------------------------------------------

worker_in_dir="worker"
worker_out_dir="functions"

# shellcheck disable=SC2120
task_worker__build() { # Build the worker files into a JS file.
  rm -fr "$worker_out_dir"
  push_ifs
  ifs_newline
  # shellcheck disable=SC2046
  subcmd_esbuild --bundle --format=esm --outdir="$worker_out_dir" $(find "$worker_in_dir" -type f -name "*.ts" -o -name "*.tsx") "$@"
  pop_ifs
}

task_worker__depbuild() { # Build the worker files if the source files are newer than the output files.
  if newer worker/ --than functions/
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
  if test "${NEXT_PUBLIC_PAGES_DEV_PORT+set}" = set
  then
    set -- "$@" --port "$NEXT_PUBLIC_PAGES_DEV_PORT"
  fi
  if test "${NEXT_DEV_PORT+set}" = set
  then
    set -- "$@" --binding AP_DEV_PORT="$NEXT_DEV_PORT"
  fi
  subcmd_wrangler pages dev "$@" --live-reload ./build/next
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
