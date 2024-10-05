#!/bin/sh
set -o nounset -o errexit

test "${guard_f78f5cf+set}" = set && return 0; guard_f78f5cf=-

. task.sh
. task-git.lib.sh

task_install() ( # Install in each directory.
  chdir_script
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

task_client__foo__build() ( # [args...] Build client.
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
  chdir_script
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
  script_dir_name="$(basename "$SCRIPT_DIR")"
  ln -sf "$SCRIPT_DIR" "$HOME"/"$script_dir_name"
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

subcmd_dupcheck() (
  ignore_list=":task:package.json:package-lock.json:"
  chdir_script
  base_prev=
  hash_prev=
  path_prev=
  for path in $(subcmd_git ls-files)
  do
    base=$(basename "$path")
    case "$base" in
      .*) continue;;
      README*) continue;;
    esac
    if echo "$ignore_list" | grep -q ":$base:" > /dev/null 2>&1
    then
      continue
    fi
    echo "$base" "$(sha1sum "$path" | cut -d ' ' -f 1)" "$path"
  done | sort | while read -r base hash path
  do
    # echo aa0accc "$base" "$hash" "$path" >&2
    if test "$base" = "$base_prev" && test "$hash" != "$hash_prev"
    then
      echo "Conflict:"
      echo "  $path"
      echo "  $path_prev"
    fi
    base_prev="$base"
    hash_prev="$hash"
    path_prev="$path"
  done
)

task_task_sh__copy() (
  chdir_script
  for dest in */task.sh
  do
    cp task.sh "$dest"
  done
)
