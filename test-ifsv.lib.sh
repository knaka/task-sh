# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_78b9c2d-}" = true && return 0; sourced_78b9c2d=true

. ./task.sh
. ./ifsv.lib.sh

test_ifsv_map() (
  set -o errexit

  assert_eq "FOO,BAR,BAZ," "$(IFS=, ifsv_map "foo,bar,baz," toupper_4c7e44e)"
  assert_eq "FOO,BAR,BAZ," "$(IFS=, ifsv_map "foo,bar,baz," toupper_4c7e44e _)"
  assert_eq "foo,bar,baz," "$(IFS=, ifsv_map "FOO,BAR,BAZ," tolower_542075d)"
  assert_eq "foo,bar,baz," "$(IFS=, ifsv_map "FOO,BAR,BAZ," tolower_542075d _)"
)

test_ifsv_filter() (
  set -o errexit

  assert_eq "foo,bar,baz," "$(IFS=, ifsv_filter "foo,bar,,baz," test -n)"
  assert_eq "foo,bar,baz," "$(IFS=, ifsv_filter "foo,bar,,baz," test -n _)"
  assert_eq "4,5,6,7," "$(IFS=, ifsv_filter "1,2,3,4,5,6,7," test _ -gt 3)"
)

test_ifsv_reduce() (
  set -o errexit

  # shellcheck disable=SC2317
  add() (
    echo $(( $1 + $2 ))
  )

  assert_eq 10 "$(IFS=, ifsv_reduce "1,2,3,4" 0 add)"

  # shellcheck disable=SC1102
  # shellcheck disable=SC2005
  # shellcheck disable=SC2086
  # shellcheck disable=SC2046
  # shellcheck disable=SC2317
  rpn() { echo $(($1 $3 $2)); }
  assert_eq 10 "$(IFS="|" ifsv_reduce "4|3|2|1" 0 rpn _ _ '+')"
  assert_eq 24 "$(IFS="|" ifsv_reduce "4|3|2|1" 1 rpn _ _ '*')"

)

# Test plist functions.
test_plist() (
  set -o errexit

  IFS=,
  csvpl=
  csvpl="$(ifsm_put "$csvpl" "key1" "val1")"
  csvpl="$(ifsm_put "$csvpl" "key2" "val2")"

  assert_eq "key1,key2," "$(ifsm_keys "$csvpl")"
  assert_eq "" "$(ifsm_keys "")"

  assert_eq "val1,val2," "$(ifsm_values "$csvpl")"
  assert_eq "" "$(ifsm_values "")"

  assert_eq "val2" "$(ifsm_get "$csvpl" "key2")"
  assert_false ifsm_get "$csvpl" "key3"

  assert_eq "key1,mod1,key2,val2," "$(ifsm_put "$csvpl" "key1" "mod1")"
  assert_eq "key1,val1,key2,val2,key3,val3," "$(ifsm_put "$csvpl" "key3" "val3")"

  assert_eq "key1,val1,key2,," "$(ifsm_put "$csvpl" "key2" "")"
  assert_eq "" "$(ifsm_get "key1,val1,key2," "key2")"

  assert_eq "key1,val1,key2,val2,,empty," "$(ifsm_put "$csvpl" "" "empty")"
  assert_eq "empty" "$(ifsm_get "key1,val1,key2,val2,,empty" "")"

  IFS="$us"
  usvpl=
  usvpl=$(ifsm_put "$usvpl" "foo bar" "FOO BAR")
  usvpl=$(ifsm_put "$usvpl" "baz qux" "BAZ QUX")
  assert_eq "foo bar${us}FOO BAR${us}baz qux${us}BAZ QUX${us}" "$usvpl"
  assert_eq "BAZ QUX" "$(ifsm_get "$usvpl" "baz qux")"
)
