#!/bin/sh
set -o nounset -o errexit

test "${guard_c43d095+set}" = set && return 0; guard_c43d095=x

. ./task.sh

# shellcheck disable=SC2034
if test -t 1
then
  RED=$(printf "\e[31m")
  GREEN=$(printf "\e[32m")
  MAGENTA=$(printf "\e[35m")
  NORMAL=$(printf "\e[00m")
  BOLD=$(printf "\e[01m")
else
  RED=""
  GREEN=""
  MAGENTA=""
  NORMAL=""
  BOLD=""
fi

# Call the test in a subshell exiting on error.
call_test() (
  set -o errexit
  "$1"
)

subcmd_test() ( # [test_names...] Run tests. If no test names are provided, all tests are run.
  psv_test_file_paths=
  # Source all the test functions in the test files.
  for test_file_path in "$SCRIPT_DIR"/test-*.sh
  do
    if ! test -r "$test_file_path"
    then
      continue
    fi
    verbose && echo Reading test file: "$test_file_path" >&2
    # shellcheck disable=SC1090
    . "$test_file_path"
    psv_test_file_paths="$psv_test_file_paths$test_file_path|"
  done
  # If not test names are provided, run all tests.
  if test "$#" -eq 0
  then
    push_ifs
    unset IFS
    # shellcheck disable=SC2046
    set -- $(
      IFS='|'
      for test_file_path in $psv_test_file_paths
      do
        unset
        sed -E -n -e 's/^test_([_[:alnum:]]+)\(\).*/\1/p' "$test_file_path" \
        | while read -r test_name
        do
          echo "$test_name"
        done
      done
      # done \
      # | shuf # Randomize the order of tests.
    )
    pop_ifs
  fi
  some_failed=false
  log_file_path="$(temp_dir_path)/485d347"
  verbose && echo "Running tests: $*" >&2
  for test_name in "$@"
  do
    if ! type "test_$test_name" 2>/dev/null | grep -q -E -e 'function$'
    then
      echo "Test not found: $test_name" >&2
      exit 1
    fi
    backup_shell_flags
    # Not to exit when each test fails.
    set +o errexit
    call_test "test_$test_name" > "$log_file_path" 2>&1
    # "test_$test_name" > "$log_file_path" 2>&1
    if test "$?" -eq 0
    then
      printf "%sTest \"%s\" Passed%s\n" "$GREEN" "$test_name" "$NORMAL" >&2
      if verbose
      then
        while IFS= read -r line
        do
          echo "  $line"
        done < "$log_file_path"
      fi
    else
      printf "%sTest \"%s\" Failed%s\n" "$RED" "$test_name" "$NORMAL" >&2
      while IFS= read -r line
      do
        echo "  $line"
      done <"$log_file_path"
      some_failed=true
    fi
    restore_shell_flags
  done
  if $some_failed
  then
    exit 1
  fi
)
