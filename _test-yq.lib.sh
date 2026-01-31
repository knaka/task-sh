# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_32dc20e-false}" && return 0; sourced_32dc20e=true

. ./_assert.lib.sh
. ./yq.lib.sh

yq_expected() {
  cat <<EOF
user:
  name: Alice
  age: 30
items:
  - apple
  - banana
EOF
}

test_yq() {
  # Fetches yq(1)
  skip_unless_full

  local expected="$TEMP_DIR/0b5a56d.yaml"
  yq_expected >"$expected"

  local actual="$TEMP_DIR/af6de1c.yaml"
  echo '{"user":{"name":"Alice","age":30},"items":["apple","banana"]}' \
  | yq --input-format=json --output-format=yaml \
  >"$actual"

  assert_eq \
    -m "7f82a42" \
    "$(sha256sum "$expected" | field 1)" \
    "$(sha256sum "$actual" | field 1)"
}
