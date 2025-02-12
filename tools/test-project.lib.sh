# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_22ca2c6-}" = true && return 0; sourced_22ca2c6=true

. ./task-bcrypt.lib.sh
. ./assert.lib.sh

test_bcrypt() {
  local password=5f7684b
  local hash
  hash="$(subcmd_bcrypt__hash "$password")"
  assert_true test -n "$hash"
  assert_true subcmd_bcrypt__verify --password="$password" --hash="$hash"
  assert_false subcmd_bcrypt__verify --password="wrong" --hash="$hash"
}
