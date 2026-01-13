# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_89e137c-}" = true && return 0; sourced_89e137c=true

# Evaluated in $TASKS_DIR.

. ./task.sh

if ! test -L "$PROJECT_DIR"/symlinked-task-sh
then
  # shellcheck disable=SC2016
  echo 'Git work seems not checked out with symlinks support. Configure with `git config --global core.symlinks true` and check out again.' >&2
  if is_windows
  then
    echo "To enable symlink creation on Windows, enable Developer Mode or run as Administrator." >&2
  fi
  exit 1
fi

. ./docker.lib.sh

repl_usage() {
  echo "exit: Exit the program." >&2
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

task_ () {
  local log; log="$TEMP_DIR"/dupcheck.log || return $?
  grep --extended-regexp --no-filename -e '^task_' -e '^subcmd_' ./*.sh \
  | sed -E -e 's/^(task_|subcmd_)//' \
  | sed -E -e 's/\(.*//' \
  | sort | uniq -d | tee "$log" \
  # nop
  test -s "$log" && return 1 || :
}

subcmd_wait_and_date() {
  echo My PID: "$$" >&2
  local name="$1"
  sleep 1
  LC_ALL=C date
  echo "Done: $name" >&2
}
