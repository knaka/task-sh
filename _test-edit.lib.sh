# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_c28ce41-false}" && return 0; sourced_c28ce41=true

. ./task.sh
. ./_edit.lib.sh
. ./_assert.lib.sh

expected_bbb4bff() {
  cat <<EOF
hello() {
  echo Hello
}
EOF
}

path_7dad95b=./testdata/hello.sh
path_c8fe7b4=./testdata/hello.txt

test_edit() {
  local function function_line_num
  function="$(extract_block "^hello()" "^}" "$path_7dad95b")"
  assert_eq "$(expected_bbb4bff)" "$function"
  function_line_num="$(echo "$function" | wc -l)"
  assert test 3 -eq "$function_line_num"

  local count_before count_after
  count_before="$(wc -l <"$path_7dad95b")"
  count_after="$(exclude_block "^hello()" "^}" "$path_7dad95b" | wc -l)"
  assert test $((count_before - function_line_num)) -eq "$count_after"

  assert test 4 -eq "$(extract_before 881e6d7 "$path_c8fe7b4" | wc -l)"
  assert test 5 -eq "$(extract_after 881e6d7 "$path_c8fe7b4" | wc -l)"
}
