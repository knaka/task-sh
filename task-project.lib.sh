# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_89e137c-}" = true && return 0; sourced_89e137c=true

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

subcmd_docker__ubuntu__run() { # Run a command in an Ubuntu Docker container.
  task_docker__start__temp
  subcmd_docker run --rm -it -v "$(pwd):/work" "$(subcmd_docker build --quiet --file ubuntu.Dockerfile .)" "$@"
}

task_docker__ubuntu__test() { # Run tests in an Ubuntu Docker container.
  subcmd_docker__ubuntu__run ./task test
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

subcmd_docker__alpine__run() { # Run a command in an Alpine Docker container.
  task_docker__start__temp
  subcmd_docker run --rm -it -v "$(pwd):/work" "$(subcmd_docker build --quiet --file alpine.Dockerfile .)" "$@"
}

task_docker__alpine__test() { # Run tests in an Alpine Docker container.
  subcmd_docker__alpine__run ./task test
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

subcmd_modcheck() { # [dir1] [dir2] Check for modifications of task files in two directories.
  local add_pattern='{\+.*\+\}'
  local rem_pattern='\[\-.*\-\]'
  local mod_pattern="$rem_pattern$add_pattern"

  local rc=0
  local dir1_path="$1"
  if ! test -d "$dir1_path"
  then
    echo "Directory not found: $dir1_path" >&2
    return 1
  fi
  local dir2_path="$2"
  if ! test -d "$dir2_path"
  then
    echo "Directory not found: $dir2_path" >&2
    return 1
  fi
  local file1_path
  for file1_path in "$dir1_path"/task.sh "$dir1_path"/*.lib.sh
  do
    if ! test -r "$file1_path"
    then
      continue
    fi
    local file2_path
    file2_path="$dir2_path"/"$(basename "$file1_path")"
    if ! test -r "$file2_path"
    then
      continue
    fi
    if ! diff -q "$file1_path" "$file2_path" >/dev/null 2>&1
    then
      num_mod="$(git diff --word-diff --unified=0 "$file1_path" "$file2_path" | grep -c -E -e "$mod_pattern" || :)"
      num_add="$(git diff --word-diff --unified=0 "$file1_path" "$file2_path" | grep -c -E -e "^$add_pattern$" || :)"
      num_rem="$(git diff --word-diff --unified=0 "$file1_path" "$file2_path" | grep -c -E -e "^$rem_pattern$" || :)"
      # shellcheck disable=SC2015
      printf "%s%s%s%s\n" \
        "$(basename "$file1_path")" \
        "$(test "$num_add" -gt 0 && echo " Added: $num_add," || :)" \
        "$(test "$num_rem" -gt 0 && echo " Removed: $num_rem," || :)" \
        "$(test "$num_mod" -gt 0 && echo " Modified: $num_mod," || :)" \
      | sed -e 's/,$//'
      diff -u "$file1_path" "$file2_path" | sed -e 's/^/  /'
      rc=1
    fi
  done
  return "$rc"
}

task_dupcheck() {
  local log_path
  log_path="$(get_temp_dir_path)"/dupcheck.log
  grep --extended-regexp --no-filename -e '^task_' -e '^subcmd_' ./lib/*.sh \
  | sed -E -e 's/^(task_|subcmd_)//' \
  | sed -E -e 's/\(.*//' \
  | sort | uniq -d | tee "$log_path"
  if test -s "$log_path"
  then
    return 1
  fi
}
