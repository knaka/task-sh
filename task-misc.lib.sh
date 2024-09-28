#!/bin/sh
set -o nounset -o errexit

test "${guard_f78f5cf+set}" = set && return 0; guard_f78f5cf=-

. task.sh

task_install() ( # Install in each directory.
  cd "$script_dir_path" || exit 1
  for dir in sh go py js
  do
    if ! test -d "$dir"
    then
      continue
    fi
    echo "Installing in $dir" >&2
    (
      cd "$dir" || exit 1
      sh ./task.sh install
    )
  done
)

task_client__build() ( # [args...] Build client.
  printf "Building client: "
  delim=
  for arg in "$@"
  do
    printf "%s%s" "$delim" "$arg"
    delim=", "
  done
  echo
)

task_client__deploy() ( # [args...] Deploy client.
  printf "Deploying client: "
  delim=""
  for arg in "$@"
  do
    printf "%s%s" "$delim" "$arg"
    delim=", "
  done
  echo
)

task_task_cmd__copy() ( # Copy task.cmd to each directory.
  cd "$script_dir_path" || exit 1
  for dir in *
  do
    if ! test -d "$dir"
    then
      continue
    fi
    cp -f task.cmd "$dir"/task.cmd
  done
)

task_home_link() ( # Link this directory to home.
  script_dir_name="$(basename "$script_dir_path")"
  ln -sf "$script_dir_path" "$HOME"/"$script_dir_name"
)

subcmd_env() ( # Show environment.
  echo "APP_SENV:" "${APP_SENV:-}"
  echo "APP_ENV:" "${APP_ENV:-}"
)

# Mock for test of help.
delegate_tasks() (
  cd "$(dirname "$0")" || exit 1
  case "$1" in
    tasks)
      echo "exclient:build     Build client."
      echo "exclient:deploy    Deploy client."
      ;;
    subcmds)
      echo "exgit       Run git command."
      echo "exdocker    Run docker command."
      ;;
    extra:install)
      echo Installing extra commands...
      echo Done
      ;;
    *)
      echo "Unknown task: $1" >&2
      return 1
      ;;
  esac
)

subcmd_newer() {
  newer "$@"
}
