# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_e85d241-false}" && return 0; sourced_e85d241=true

. ./task.sh

should_run_fulltest_80e79eb=false

# Skip this test unless full test is being run.
skip_unless_full() {
  if $should_run_fulltest_80e79eb
  then
    return 0
  fi
  return "$rc_test_skipped"
}

skip_if() {
  if "$@"
  then
    return "$rc_test_skipped"
  fi
}

skip_unless() {
  ! skip_if "$@"
}

# Run shell-based tests for tasks. If no test names are provided, all tests are run.
subcmd_task__test() {
  OPTIND=1; while getopts a-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (full) should_run_fulltest_80e79eb=true;;
      (*)
        echo "Unexpected option: $OPT" >&2
        exit 1
        ;;
    esac
  done
  shift $((OPTIND-1))

  local RED=""
  local GREEN=""
  local YELLOW=""
  local NORMAL=""
  if is_terminal
  then
    RED=$(printf "\033[31m")
    GREEN=$(printf "\033[32m")
    YELLOW=$(printf "\033[33m")
    NORMAL=$(printf "\033[00m")
  fi

  local psv_test_file_paths=
  # Source all the test functions in the test files.
  push_dir "$TASKS_DIR"
  for test_file_path in "$TASKS_DIR"/_test-*.sh
  do
    test -r "$test_file_path" || continue
    "$VERBOSE" && echo Reading test file: "$test_file_path" >&2
    # shellcheck disable=SC1090
    . "$test_file_path"
    psv_test_file_paths="$psv_test_file_paths$test_file_path|"
  done
  pop_dir
  # If no test names are provided, run all.
  if test $# -eq 0
  then
    echo "No test names provided. Running all tests." >&2
    # shellcheck disable=SC2046
    set -- $(
      IFS='|'
      for test_file_path in $psv_test_file_paths
      do
        sed -E -n -e 's/^test_([_[:alnum:]]+)\(\).*/\1/p' "$test_file_path" \
        | while read -r test_name
          do
            echo "$test_name"
          done
      done \
      | shuf
    )
  fi
  local some_failed=false
  local log_file_path="$TEMP_DIR"/485d347
  "$VERBOSE" && echo "Running tests: $*" >&2
  local test_name
  for test_name in "$@"
  do
    if ! LC_ALL=C type "test_$test_name" 2>/dev/null | grep -q -E -e 'function$'
    then
      echo "Test not found: $test_name" >&2
      exit 1
    fi
    local saved_flags
    saved_flags="$(set +o)"
    case $- in
      (*e*) saved_flags="$saved_flags; set -e";;
      (*) saved_flags="$saved_flags; set +e";;
    esac
    # Do not exit when each test fails.
    set +o errexit
    # Run test in a subshell with errexit enabled. This allows the test to exit immediately on error while the parent shell continues to run subsequent tests.
    # (
    #   set -o errexit
    #   "test_$test_name"
    # ) >"$log_file_path" 2>&1
    echo >"$log_file_path"
    (
      set -o errexit
      echo 9cd68b9 >&2
      type "test_$test_name" >&2
      echo ec1f551 >&2
      "test_$test_name"
    )
    local rc=$?
    echo "d090613" "$rc" >&2
    eval "$saved_flags"
    if test "$rc" -eq 0
    then
      printf "%sTest \"%s\" Passed%s\n" "$GREEN" "$test_name" "$NORMAL" >&2
      if "$VERBOSE"
      then
        sed -e 's/^/  /' <"$log_file_path" >&2
      fi
    elif test "$rc" -eq "$rc_test_skipped"
    then
      printf "%sTest \"%s\" Skipped%s\n" "$YELLOW" "$test_name" "$NORMAL" >&2
    else
      printf "%sTest \"%s\" Failed with RC %d%s\n" "$RED" "$test_name" "$rc" "$NORMAL" >&2
      sed -e 's/^/  /' <"$log_file_path" >&2
      some_failed=true
    fi
  done
  $some_failed && return 1
  return 0
}
