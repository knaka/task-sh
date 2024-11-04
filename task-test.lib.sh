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

psv_test_file_paths=

subcmd_test() ( # [test_names...] Run tests. If no test names are provided, all tests are run.
  set +o errexit
  for test_file_path in "$SCRIPT_DIR"/test-*.sh
  do
    if ! test -r "$test_file_path"
    then
      continue
    fi
    # shellcheck disable=SC1090
    . "$test_file_path"
    psv_test_file_paths="${psv_test_file_paths:+$psv_test_file_paths|}$test_file_path"
  done
  test_names=
  if test "$#" -eq 0
  then
    temp_file_path="$(temp_dir_path)/4986280"
    set_ifs_pipe
    for test_file_path in $psv_test_file_paths
    do
      grep -E -h -e "^test_[_[:alnum:]]+\(" "$test_file_path" | sed -r -e 's/^test_//' -e "s/\(\) *[{(] *(# *)?//" > "$temp_file_path"
      while read -r test_name
      do
        test_names="${test_names:+$test_names }$test_name"
      done < "$temp_file_path"
    done
    restore_ifs
    for test_name in $test_names
    do
      set -- "$@" "$test_name"
    done
  fi
  some_failed=false
  log_file_path="$(temp_dir_path)/485d347"
  for test_name in "$@"
  do
    if ! type "test_$test_name" 2>/dev/null | grep -q -E -e 'function$'
    then
      echo "Test not found: $test_name" >&2
      exit 1
    fi
    backup_state
    # Not to exit when each test fails.
    set +o errexit
    "test_$test_name" > "$log_file_path" 2>&1
    if test "$?" -eq 0
    then
      printf "%sTest \"%s\" Passed%s\n" "$GREEN" "$test_name" "$NORMAL"
      if verbose
      then
        set_ifs_newline
        while read -r line
        do
          echo "  $line"
        done < "$log_file_path"
        restore_ifs
      fi
    else
      printf "%sTest \"%s\" Failed%s\n" "$RED" "$test_name" "$NORMAL"
      set_ifs_newline
      while read -r line
      do
        echo "  $line"
      done < "$log_file_path"
      restore_ifs
      some_failed=true
    fi
    restore_state
  done
  if $some_failed
  then
    exit 1
  fi
)
