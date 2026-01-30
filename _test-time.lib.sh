# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_6cc6268-false}" && return 0; sourced_6cc6268=true

. ./task.sh
. ./_time.lib.sh
. ./_assert.lib.sh

test_time() {
  local result

  result="$(date_iso)"
  assert_match '\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+\d{4}' "$result"

  result="$(TZ=UTC0 date_iso)"
  assert_match '\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+0000' "$result"

  local file="$TEMP_DIR"/file

  set_last_mod_iso "$file" "2024-01-01T12:00:00Z"
  assert_eq "$(TZ=UTC0 last_mod_iso "$file")" "2024-01-01T12:00:00+0000"

  set_last_mod_iso "$file" "2024-01-01T09:00:00+0900"
  assert_eq "$(TZ=UTC0 last_mod_iso "$file")" "2024-01-01T00:00:00+0000"
}
