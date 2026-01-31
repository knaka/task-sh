# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_23969e5-false}" && return 0; sourced_23969e5=true

. ./_assert.lib.sh
. ./json2sh.lib.sh

json2sh_expected() {
  cat <<EOF
json__user__name="Alice"
json__user__age="30"
json__items__0="apple"
json__items__1="banana"
EOF
}

test_json2sh() {
  # Fetches jq(1)
  skip_unless_full

  local expected="$TEMP_DIR/390f638.sh"
  json2sh_expected >"$expected"

  local actual="$TEMP_DIR/d06580e.sh"
  echo '{"user":{"name":"Alice","age":30},"items":["apple","banana"]}' | json2sh >"$actual"

  assert_eq \
    "$(sha256sum "$expected" | field 1)" \
    "$(sha256sum "$actual" | field 1)"
}
