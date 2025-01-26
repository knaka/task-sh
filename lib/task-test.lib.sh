#!/bin/sh
set -o nounset -o errexit

test "${guard_c43d095+set}" = set && return 0; guard_c43d095=x

. ./task.sh

# shellcheck disable=SC2034
if test -t 1
then
  RED=$(printf "\e[31m")
  GREEN=$(printf "\e[32m")
  YELLOW=$(printf "\e[33m")
  MAGENTA=$(printf "\e[35m")
  NORMAL=$(printf "\e[00m")
  BOLD=$(printf "\e[01m")
else
  RED=""
  GREEN=""
  YELLOW=""
  MAGENTA=""
  NORMAL=""
  BOLD=""
fi

# Call the test in a subshell exiting on error.
call_test() (
  set -o errexit
  "$1"
)

should_test_all=${SHOULD_TEST_ALL:-false}

# Skip the test unless all tests are run.
skip_unless_all() {
  $should_test_all && return 0
  return "$rc_test_skipped"
}

subcmd_task__test() ( # [test_names...] Run shell-based tests for tasks. If no test names are provided, all tests are run.
  unset OPTIND; while getopts a-: OPT
  do
    if test "$OPT" = "-"
    then
      # Extract long option name.
      # shellcheck disable=SC2031
      OPT="${OPTARG%%=*}"
      # Extract long option argument.
      # shellcheck disable=SC2031
      OPTARG="${OPTARG#"$OPT"}"
      OPTARG="${OPTARG#=}"
    fi
    case "$OPT" in
      (a|all) should_test_all=true;;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

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
    echo "No test names provided. Running all tests." >&2
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
    result=$?
    if test "$result" -eq 0
    then
      printf "%sTest \"%s\" Passed%s\n" "$GREEN" "$test_name" "$NORMAL" >&2
      if verbose
      then
        while IFS= read -r line
        do
          echo "  $line"
        done < "$log_file_path"
      fi
    elif test "$result" -eq "$rc_test_skipped"
    then
      printf "%sTest \"%s\" Skipped%s\n" "$YELLOW" "$test_name" "$NORMAL" >&2
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
