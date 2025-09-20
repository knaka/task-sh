# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_a1e28be-false}" && return 0; sourced_a1e28be=true

. ./task.sh
. ./_misc.lib.sh

args_restore_test() {
  local before1 before2 before3
  before1="$1"
  before2="$2"
  before3="$3"

  local eval_args
  eval_args="$(make_eval_args "$@")"

  set --
  assert_true test $# -eq 0

  eval "set -- $eval_args"

  assert_true test $# -eq 3

  assert_eq "$before1" "$1"
  assert_eq "$before2" "$2"
  assert_eq "$before3" "$3"
}

test_args_restore() {
  args_restore_test "hoge ' fuga" 'foo " bar' "$(printf "bar\nbaz")"
}

test_memoize_block() {
  if begin_memoize 3383e2e
  then
    echo "hello"
    echo "world"
    end_memoize
  fi
}
