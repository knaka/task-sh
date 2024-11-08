#!/bin/sh
set -o nounset -o errexit

# test "${guard_f78f5cf+set}" = set && return 0; guard_f78f5cf=x

. ./task.sh
. ./task-git.lib.sh

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
    if ! test -r "$dir"/task.cmd
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
    (tasks)
      echo "exclient:build               Build client."
      echo "exclient:deploy              Deploy client."
      ;;
    (subcmds)
      echo "exgit       Run git command."
      echo "exdocker    Run docker command."
      ;;
    (extra:install)
      echo Installing extra commands...
      echo Done
      ;;
    (*)
      echo "Unknown task: $1" >&2
      return 1
      ;;
  esac
)

subcmd_newer() { # Check newer files.
  newer "$@"
}

task_dupcheck() ( # Check duplicate files.
  base_prev=
  hash_prev=
  path_prev=
  subcmd_git ls-files | while read -r path
  do
    case "$path" in
      (next/app/*) continue;;
    esac
    base=$(basename "$path")
    case "$base" in
      (*.rs) continue;;
      (.*) continue;;
      (Cargo.*) continue;;
      (README*) continue;;
      (package-lock.json) continue;;
      (package.json) continue;;
      (page.tsx) continue;;
      (task) continue;;
      (task-prj*.lib.sh) continue;;
      (task-project*.lib.sh) continue;;
      (tsconfig.json) continue;;
    esac
    # shellcheck disable=SC2046
    echo "$base|$(sha1sum "$path" | (read -r hash _; echo "$hash"))|$path"
  done | sort | while IFS='|' read -r base hash path
  do
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

task_task_cmd__rename_copy() (
  for dest in */*.cmd
  do
    if ! test -r "$dest"
    then
      continue
    fi
    if test "$(dirname "$dest")" = "cmd"
    then
      continue
    fi
    case "$(basename "$dest")" in
      go-embedded.cmd)
        continue
        ;;
    esac
    cp -f task.cmd "$dest"
  done
)

task_task_sh__copy() (
  chdir_script
  for dest in */task.sh
  do
    cp task.sh "$dest"
  done
)

task_hello1() {
  while true
  do
    echo hello1
    sleep 1
  done
}

task_hello2() (
  while true
  do
    echo hello2
    sleep 1
  done
)

task_daemon() {
  task_hello1 &
  # task_hello2 &
  (
    while true
    do
      echo hello3
      sleep 1
    done
  ) &
  sleep 3
  kill_children
}

task_once() {
  echo Started Once >&2
  first_call 4012815 || return 0
  echo Doing Once >&2
}

subcmd_foo__bar() {
  cat <<EOF | sort_version
1.1.1
1.0
1.1.1alpha1
EOF
}

subcmd_bar__baz__hoge__fuga() { # Bar baz.
  echo "Bar baz"
}
