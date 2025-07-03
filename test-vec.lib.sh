# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_c3a9b1f-}" = true && return 0; sourced_c3a9b1f=true

. ./task.sh

test_vec_map() (
  set -o errexit

  assert_eq "FOO${us}BAR${us}BAZ${us}" "$(vec_map "foo${us}bar${us}baz${us}" toupper_4c7e44e)"
  assert_eq "FOO${us}BAR${us}BAZ${us}" "$(vec_map "foo${us}bar${us}baz${us}" toupper_4c7e44e _)"
  assert_eq "foo${us}bar${us}baz${us}" "$(vec_map "FOO${us}BAR${us}BAZ${us}" tolower_542075d)"
  assert_eq "foo${us}bar${us}baz${us}" "$(vec_map "FOO${us}BAR${us}BAZ${us}" tolower_542075d _)"
)

test_vec_filter() (
  set -o errexit

  assert_eq "foo${us}bar${us}baz${us}" "$(vec_filter "foo${us}bar${us}${us}baz${us}" test -n)"
  assert_eq "foo${us}bar${us}baz${us}" "$(vec_filter "foo${us}bar${us}${us}baz${us}" test -n _)"
  assert_eq "4${us}5${us}6${us}7${us}" "$(vec_filter "1${us}2${us}3${us}4${us}5${us}6${us}7${us}" test _ -gt 3)"
)

test_vec_reduce() (
  set -o errexit

  # shellcheck disable=SC2317
  add() (
    echo $(( $1 + $2 ))
  )

  assert_eq 10 "$(vec_reduce "1${us}2${us}3${us}4" 0 add)"

  # shellcheck disable=SC1102
  # shellcheck disable=SC2005
  # shellcheck disable=SC2086
  # shellcheck disable=SC2046
  # shellcheck disable=SC2317
  rpn() { echo $(($1 $3 $2)); }
  assert_eq 10 "$(vec_reduce "4${us}3${us}2${us}1" 0 rpn _ _ '+')"
  assert_eq 24 "$(vec_reduce "4${us}3${us}2${us}1" 1 rpn _ _ '*')"

)

# Test plist functions.
test_plist() (
  set -o errexit

  usvpl=
  usvpl="$(vec_put "$usvpl" "key1" "val1")"
  usvpl="$(vec_put "$usvpl" "key2" "val2")"

  assert_eq "key1${us}key2${us}" "$(vec_keys "$usvpl")"
  assert_eq "" "$(vec_keys "")"

  assert_eq "val1${us}val2${us}" "$(vec_values "$usvpl")"
  assert_eq "" "$(vec_values "")"

  assert_eq "val2" "$(vec_get "$usvpl" "key2")"
  assert_false vec_get "$usvpl" "key3"

  assert_eq "key1${us}mod1${us}key2${us}val2${us}" "$(vec_put "$usvpl" "key1" "mod1")"
  assert_eq "key1${us}val1${us}key2${us}val2${us}key3${us}val3${us}" "$(vec_put "$usvpl" "key3" "val3")"

  assert_eq "key1${us}val1${us}key2${us}${us}" "$(vec_put "$usvpl" "key2" "")"
  assert_eq "" "$(vec_get "key1${us}val1${us}key2${us}" "key2")"

  assert_eq "key1${us}val1${us}key2${us}val2${us}${us}empty${us}" "$(vec_put "$usvpl" "" "empty")"
  assert_eq "empty" "$(vec_get "key1${us}val1${us}key2${us}val2${us}${us}empty" "")"

  usvpl2=
  usvpl2=$(vec_put "$usvpl2" "foo bar" "FOO BAR")
  usvpl2=$(vec_put "$usvpl2" "baz qux" "BAZ QUX")
  assert_eq "foo bar${us}FOO BAR${us}baz qux${us}BAZ QUX${us}" "$usvpl2"
  assert_eq "BAZ QUX" "$(vec_get "$usvpl2" "baz qux")"
)
