# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_344ba65-false}" && return 0; sourced_344ba65=true

. ./task.sh
. ./test.lib.sh
. ./_assert.lib.sh
. ./yq.lib.sh

test_toml() {
  
  assert_eq 1 1
}
