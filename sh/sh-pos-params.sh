#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_a1b295c-}" = true && return 0; sourced_a1b295c=true
set -o nounset -o errexit


foo() {
  local before1 before2 before3
  before1="$1"
  before2="$2"
  before3="$3"

  local original_args_encoded
  original_args_encoded="$(encode_args "$@")"

  set --
  test $# -eq 0

  eval "set -- $(decode_args_for_eval "$original_args_encoded")"

  test "$before1" = "$1"
  test "$before2" = "$2"
  test "$before3" = "$3"
}

foo "hoge ' fuga" 'foo " bar' "$(printf "bar\nbaz")"
