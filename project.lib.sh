# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_89e137c-}" = true && return 0; sourced_89e137c=true

# Evaluated in $TASKS_DIR.

. ./task.sh

# if ! test -L "$PROJECT_DIR"/sh/task.sh
# then
#   # shellcheck disable=SC2016
#   echo 'Git work seems not checked out with symlinks support. Configure with `git config --global core.symlinks true` and check out again.' >&2
#   if is_windows
#   then
#     echo "To enable symlink creation on Windows, enable Developer Mode or run as Administrator." >&2
#   fi
#   exit 1
# fi

. ./docker.lib.sh

repl_usage() {
  echo "exit: Exit the program."
}

# Start a REPL.
task_repl() {
  while true
  do
    printf "> "
    IFS= read -r line
    case "$line" in
      (exit) break;;
      ("") repl_usage;;
      (*)
        local saved_shell_flags="$(set +o)"
        set +o errexit
        eval "$line"
        echo "exit status: $?" >&2
        eval "$saved_shell_flags"
        ;;
    esac
  done
}

# Run a command in an Ubuntu Docker container.
subcmd_docker__ubuntu__exec() {
  task_docker__start__temp
  subcmd_docker run --rm -it -v "$(pwd):/work" "$(subcmd_docker build --quiet --file ubuntu.Dockerfile .)" "$@"
}

# Run tests in an Ubuntu Docker container.
task_docker__ubuntu__test() {
  subcmd_docker__ubuntu__exec ./task test
}

# Run a command in a Debian Docker container.
subcmd_docker__debian__exec() {
  task_docker__start__temp
  subcmd_docker run --rm -it -v "$(pwd):/work" "$(subcmd_docker build --quiet --file debian.Dockerfile .)" "$@"
}

# Run tests in a Debian Docker container.
task_docker__debian__test() {
  subcmd_docker__debian__exec ./task test
}

# Run a command in a BusyBox Docker container.
subcmd_docker__busybox__exec() {
  task_docker__start__temp
  subcmd_docker run --rm -it -v "$(pwd):/work" "$(subcmd_docker build --quiet --file busybox.Dockerfile .)" "$@"
}

# Run tests in a BusyBox Docker container.
task_docker__busybox__test() {
  subcmd_docker__busybox__exec ./task test
}

# Run a command in an Alpine Docker container.
subcmd_docker__alpine__exec() {
  task_docker__start__temp
  subcmd_docker run --rm -it -v "$(pwd):/work" "$(subcmd_docker build --quiet --file alpine.Dockerfile .)" "$@"
}

# Run tests in an Alpine Docker container.
task_docker__alpine__test() {
  subcmd_docker__alpine__exec ./task test
}

# Do nothing.
task_nop() {
  :
}

# Detect differences from the directory.
subcmd_diff() {
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

# csv_projects_to_install=sh,go,js

# task_install() { # Install in each directory.
#   push_ifs
#   IFS=,
#   for dir in $csv_projects_to_install
#   do
#     echo "Installing in $dir" >&2
#     (
#       cd "$dir" || exit 1
#       # sh ./task.sh --skip-missing install
#       # --ignore-missing: Prints warning if the task is not found.
#       sh ./task.sh --ignore-missing install
#     )
#   done
#   pop_ifs
# }

readonly task_bin_dir_path="$HOME"/task-bin

install_task_bin() {
  local dir="$1"
  local task_name="$2"
  local name="${3:-$task_name}"
  cat <<EOF >"$task_bin_dir_path"/"$name".sh
#!/bin/sh
export PROJECT_DIR="$PWD"/"$dir"
exec "\$SH" "$PWD"/"$dir"/task.sh "$task_name" "\$@"
EOF
  if is_windows
  then
    cp -a "$PWD"/task.cmd "$task_bin_dir_path"/"$name".cmd
  else
    cp -a "$PWD"/task "$task_bin_dir_path"/"$name"
  fi
}

# [args...] Build client.
task_client__foo__build() (
  printf "Building client: "
  delim=
  for arg in "$@"
  do
    printf "%s%s" "$delim" "$arg"
    delim=", "
  done
  echo
)

# [args...] Deploy client.
task_client__deploy() (
  printf "Deploying client: "
  delim=""
  for arg in "$@"
  do
    printf "%s%s" "$delim" "$arg"
    delim=", "
  done
  echo
)

# Copy task.cmd to each directory.
task_task_cmd__copy() (
  for path in */task*.cmd
  do
    if ! test -e "$path"
    then
      continue
    fi
    cp -f task.cmd "$path"
  done
)

# Link this directory to home.
task_home_link() (
  script_dir_name="$(basename "$SCRIPT_DIR")"
  ln -sf "$SCRIPT_DIR" "$HOME"/"$script_dir_name"
)

# Show environment.
subcmd_env() (
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

# Check newer files.
subcmd_newer() {
  newer "$@"
}

# [test_names...] Run shell-based tests for tasks. If no test names are provided, all tests are run.
subcmd_test() {
  echo "Running tests with shell ${SH}."
  subcmd_task__test "$@"
}

# [dir1 dir2] Check for modifications of task files in two directories.
subcmd_modcheck() {
  local add_pattern='{\+.*\+\}'
  local rem_pattern='\[\-.*\-\]'
  local mod_pattern="$rem_pattern$add_pattern"

  local files="$TEMP_DIR"/b3f3106
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
    case "${file1_path##*/}" in
      (prj.lib.sh|project.lib.sh) continue;;
    esac
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
      echo "$file2_path" >>"$files"
    fi
  done
  if test -e "$files"
  then
    echo >&2
    echo "Modified files:" >&2
    cat "$files" >&2
    return 1
  fi
  return 0
}

task_dupcheck() {
  local log_path
  log_path="$TEMP_DIR"/dupcheck.log
  grep --extended-regexp --no-filename -e '^task_' -e '^subcmd_' ./*.sh \
    | sed -E -e 's/^(task_|subcmd_)//' \
    | sed -E -e 's/\(.*//' \
    | sort | uniq -d | tee "$log_path" \
    # nop
  if test -s "$log_path"
  then
    return 1
  fi
}

subcmd_wait_and_date() {
  echo My PID: "$$" >&2
  local name="$1"
  sleep 1
  LC_ALL=C date
  echo "Done: $name" >&2
}

is_ci() {
  test "${CI+set}" = set
}

is_ci_macos() {
  is_ci && is_macos
}

subcmd_run_processes() {
  local parent_temp_dir_path="$1"

  bg_exec /bin/sleep 10
  bg_exec \
    "$SH" task.sh wait_and_date process0
  bg_exec \
    --stdout="$parent_temp_dir_path"/process1-stdout.log \
    "$SH" task.sh wait_and_date process1
  bg_exec \
    --stderr="$parent_temp_dir_path"/process2-stderr.log \
    "$SH" task.sh wait_and_date process2
  bg_exec \
    --stdout="$parent_temp_dir_path"/process3-merged.log \
    --stderr="$parent_temp_dir_path"/process3-merged.log \
    "$SH" task.sh wait_and_date process3

  local jobs_path
  jobs_path="$parent_temp_dir_path"/jobs.log

  jobs >"$jobs_path"
  if ! test "$(grep Running "$jobs_path" | cat | wc -l)" -eq 5
  then
    echo "Some jobs are not running." >&2
    return 1
  fi

  sleep 2

  jobs >"$jobs_path"
  if ! test "$(grep Running "$jobs_path" | cat | wc -l)" -eq 1
  then
    echo "Some jobs are still running." >&2
    return 1
  fi

  kill_children

  jobs >"$jobs_path"
  if ! test "$(grep Running "$jobs_path" | cat | wc -l)" -eq 0
  then
    echo "Some jobs are not killed." >&2
    return 1
  fi

  return 0
}

  # echo Launched all processes. Waiting for them to finish. >&2
  # echo pids: "$pids"
  # local before=
  # local pid=
  # echo 5f0646d >&2
  # pid=$$
  # echo 7f9860d >&2
  # if is_ci_macos
  # then 
  #   return 0
  # fi
  # if is_macos
  # then
  #   :
  #   # echo 5871cc1 >&2
  #   # ps -o ppid,command "$pid" >&2
  #   # echo 591e809 >&2
  #   # # ps -o ppid,command | sed -e 's/^ *//' | grep "^$pid " >&2
  #   # ps -a -o ppid,command | sed -e 's/^ *//' | grep "^$pid " | cat >&2
  #   # echo 896bba3 >&2
  #   # echo
  #   # before="$(ps -a -o ppid,command | sed -e 's/^ *//' | grep "^$pid " | cat | wc -l)"
  # elif is_windows
  # then
  #   before="$(ps -o ppid | sed -e 's/^ *//' | grep "^$pid$" | wc -l)"
  # else
  #   before="$(ps --ppid "$pid" | wc -l)"
  # fi
  # echo Sleeping for 2 seconds. >&2
  # sleep 2
  # echo Waking up. >&2
  # if is_macos
  # then
  #   jobs >"$TEMP_DIR"/jobs.log
  #   echo 3abdbd9
  #   grep Running "$TEMP_DIR"/jobs.log | cat
  #   if ! test "$(grep Running "$TEMP_DIR"/jobs.log | cat | wc -l)" -eq 0
  #   then
  #     echo "Some jobs are still running." >&2
  #     return 1
  #   fi
  #   return 0
  # fi
  # echo >&2
  # local after=
  # if is_macos
  # then
  #   # ps -o ppid,command | sed -e 's/^ *//' | grep "^$pid " >&2
  #   # ps -o ppid | sed -e 's/^ *//' | grep "^$pid " >&2
  #   echo 450fe96 >&2
  #   ps -a -o ppid,command | sed -e 's/^ *//' | grep "^$pid " | cat >&2
  #   after="$(ps -a -o ppid,command | sed -e 's/^ *//' | grep "^$pid " | cat | wc -l)"
  # elif is_windows
  # then
  #   after="$(ps -o ppid | sed -e 's/^ *//' | grep "^$pid$" | wc -l)"
  # else
  #   after="$(ps --ppid "$pid" | wc -l)"
  # fi
  # # echo 6b12f9d: "$before" "$after"
  # if ! test $((before - after)) -eq 4
  # then
  #   echo "The number of child processes is not 4 but $before - $after." >&2
  #   return 1
  # fi
  # echo Finishing >&2
  # return 0

sleep_cmd=/bin/sleep
if is_windows
then
  sleep_cmd=sleep.exe
fi

subcmd_my_sleep_bg() {
  "$sleep_cmd" 5678 &
  wait $!
}

subcmd_my_sleep_exec() {
  kill_child_processes
  exec "$sleep_cmd" 6789
}

task_killng_test() {
  "$sleep_cmd" 1234 &
  INVOCATION_MODE=background invoke "$sleep_cmd" 2345
  "$sleep_cmd" 3456 &
  "$SH" task.sh my_sleep_bg &
  INVOCATION_MODE=background invoke ./task my_sleep_exec
  "$sleep_cmd" 1
  kill_child_processes
  "$sleep_cmd" 1
  # shellcheck disable=SC2009
  if ps ww | grep 'slee[p]'
  then
    echo "Some sleep processes are still running." >&2
    return 1
  fi
  return 0
}

task_key() {
  echo "Press a key."
  local key
  key="$(get_key)"
  printf "Key '%s' (0x%02x) pressed.\n" "$key" "'$key"
}
