# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_54bac15-false}" && return 0; sourced_54bac15=true

. ./_encoding.lib.sh

test_encoder() {
  local result encoded decoded
  result="$(echo hello | oct_encode | oct_decode)"
  assert_eq "hello" "$result"

  encoded="$(oct_encode "foo")"
  decoded="$(oct_decode "$encoded")"
  assert_eq "foo" "$decoded"

  encoded="$(oct_encode "foo" "bar")"
  decoded="$(oct_decode "$encoded")"
  assert_eq "foo bar" "$decoded"
}
