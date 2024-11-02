#!/bin/sh
set -o nounset -o errexit

test "${guard_8842fe8+set}" = set && return 0; guard_8842fe8=x

. ./assert.lib.sh
. ./task.sh

test_first() (
  :
)

test_second() (
  :
)

test_set_ifs() (
  echo Testing set_ifs_newline
  default_ifs="$IFS"
  set_ifs_newline
  assert_eq "$IFS" "$(printf '\n\r')"
  restore_ifs

  echo Testing that IFS is restored
  assert_eq "$IFS" "$default_ifs"
  IFS='abcde'
  set_ifs_pipe
  restore_ifs
  assert_eq "$IFS" "abcde"
)
