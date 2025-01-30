#!/bin/sh
test "${guard_a8ac234+set}" = set && return 0; guard_a8ac234=x

. ./task.sh

if ! test -L ./sh/task.sh
then
  # shellcheck disable=SC2016
  echo 'Git work seems not checked out with symlinks support. Configure with `git config --global core.symlinks true` and check out again.' >&2
  if is_windows
  then
    echo "To enable symlink creation on Windows, enable Developer Mode or run as Administrator." >&2
  fi
  exit 1
fi

. ./task-docker.lib.sh
. ./task-shared-git-work-dir.lib.sh

repl_usage() {
  echo "exit: Exit the program."
}

task_repl() { # Start a REPL.
  while true
  do
    printf "> "
    IFS= read -r line
    case "$line" in
      (exit) break;;
      ("") repl_usage;;
      (*)
        backup_shell_flags
        set +o errexit
        eval "$line"
        echo "exit status: $?" >&2
        restore_shell_flags
        ;;
    esac
  done
}

subcmd_docker__debian__run() { # Run a command in a Debian Docker container.
  task_docker__start__temp
  subcmd_docker run --rm -it -v "$(pwd):/work" "$(subcmd_docker build --quiet --file debian.Dockerfile .)" "$@"
}

task_docker__debian__test() { # Run tests in a Debian Docker container.
  subcmd_docker__debian__run ./task test
}

subcmd_docker__busybox__run() { # Run a command in a BusyBox Docker container.
  task_docker__start__temp
  subcmd_docker run --rm -it -v "$(pwd):/work" "$(subcmd_docker build --quiet --file busybox.Dockerfile .)" "$@"
}

task_docker__busybox__test() { # Run tests in a BusyBox Docker container.
  subcmd_docker__busybox__run ./task test
}

task_key() { # Read a key press and show its code.
  echo "Press a key."
  local key
  key="$(get_key)"
  printf "Key %02x pressed.\n" "'$key"
}

task_nop() { # Do nothing.
  :
}

subcmd_diff() { # Detect differences from the directory.
  local target_dir="${1}"
  find "${target_dir}" -type f -name "task*.sh" -maxdepth 1 \
  | while IFS= read -r theirs
  do
    base="$(basename "${theirs}")"
    case "${base}" in
      (task-prj*.sh) continue;;
    esac
    ours="$(find . -type f -name "${base}" -maxdepth 2 | head -n 1)"
    if test -z "${ours}"
    then
      continue
    fi
    if ! diff -q "${ours}" "${theirs}"
    then
      echo "Different: ${ours} ${theirs}"
      diff -u "${ours}" "${theirs}" || :
    fi
  done
}

csv_projects_to_install=sh,go,js

task_install() { # Install in each directory.
  push_ifs
  IFS=,
  for dir in $csv_projects_to_install
  do
    echo "Installing in $dir" >&2
    (
      cd "$dir" || exit 1
      # sh ./task.sh --skip-missing install
      # --ignore-missing: Prints warning if the task is not found.
      sh ./task.sh --ignore-missing install
    )
  done
  pop_ifs
}

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
  for path in */task*.cmd
  do
    if ! test -e "$path"
    then
      continue
    fi
    cp -f task.cmd "$path"
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
      return "$rc_delegate_task_not_found"
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
  # subcmd_git ls-files \
  find . -maxdepth 2 -type f \
  | while IFS= read -r path
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
      (next.config.mjs) continue;;
      (package-lock.json) continue;;
      (package.json) continue;;
      (page.tsx) continue;;
      (task) continue;;
      (task.sh) continue;;
      (task-prj*.lib.sh) continue;;
      (task-project*.lib.sh) continue;;
      (test-prj*.lib.sh) continue;;
      (test-project*.lib.sh) continue;;
      (tsconfig.json) continue;;
    esac
    # shellcheck disable=SC2046
    echo "$base|$(sha1sum "$path" | field 1)|$path"
  done \
  | sort \
  | while IFS='|' read -r base hash path
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

# task_cmd__rename_copy() (
#   for dest in */*.cmd
#   do
#     if ! test -r "$dest"
#     then
#       continue
#     fi
#     if test "$(dirname "$dest")" = "cmd"
#     then
#       continue
#     fi
#     case "$(basename "$dest")" in
#       go-embedded.cmd)
#         continue
#         ;;
#     esac
#     cp -f task.cmd "$dest"
#   done
# )

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

subcmd_test() { # [test_names...] Run shell-based tests for tasks. If no test names are provided, all tests are run.
  echo "Running tests with shell ${SH}."
  subcmd_task__test "$@"
}

task_all__test() { # Run all tests in sub directories. This can take a long time if the environment is not set up.
  local some_failed=false
  local i
  for i in js/ tools/ ./
  do
    echo "Testing $i"
    cd "$i" || exit 1
    if ! "$SH" task.sh test --all
    then
      some_failed=true
    fi
    cd ..
  done
  $some_failed && return 1
  return 0
}

subcmd_modcheck() { # Modification check.
  # if test $# -eq 0
  # then
  #   echo "Usage: $0 <dir>"
  #   return 1
  # fi
  local dir="$1"
  for i in "$dir"/task.sh "$dir"/*.lib.sh
  do
    if ! test -r "$i"
    then
      continue
    fi
    local j
    j=./lib/"$(basename "$i")"
    if ! test -r "$j"
    then
      continue
    fi
    if ! diff -q "$j" "$i"
    then
      echo "Different: $i" >&2
      diff -uNr "$j" "$i" || :
    fi
  done
}

task_nest() {
  "$shell" task.sh modcheck
}
