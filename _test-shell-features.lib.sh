# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_79f1cd8-false}" && return 0; sourced_79f1cd8=true

. ./_assert.lib.sh
. ./task.sh

# While `local` is undefined in POSIX shell, it is available on Ubuntu (dash alias), MacOS (bash alias) and Windows BusyBox (ash alias).
# 10. Files — Debian Policy Manual v4.7.0.1 https://www.debian.org/doc/debian-policy/ch-files.html#scripts
test_local_var() (
  set -o errexit

  # shellcheck disable=SC2317
  func_to_update_global() {
    foo_ae5f2b3=xyz
    assert_eq "xyz" "$foo_ae5f2b3"
  }

  foo_ae5f2b3=abc
  func_to_update_global
  assert_eq "xyz" "$foo_ae5f2b3"

  # shellcheck disable=SC2317
  func_to_update_local() {
    local foo_ae5f2b3
    foo_ae5f2b3=xyz
    assert_eq "xyz" "$foo_ae5f2b3"
  }

  foo_ae5f2b3=abc
  func_to_update_local
  assert_eq "abc" "$foo_ae5f2b3"
)

# Here string is not available on Ubuntu (dash alias) and Windows BusyBox (ash alias). Use parameter expansion in here document instead. // ShellCheck: SC3011 – In POSIX sh, here-strings are undefined. https://www.shellcheck.net/wiki/SC3011
test_here_string() (
  input="foo bar baz"
  # sed -E -e 's/bar/BAR/' <<<"$input"
  assert_eq "foo BAR baz" "$(sed -E -e 's/bar/BAR/' <<EOF
$input
EOF
)"
)

# If you do not like not-indented here doc in function, you can use indented here doc in function.
here_doc_107d344() { cat <<EOF
foo
$1
bar
EOF
}

test_indented_here_doc() (
  set -o errexit

  var=aaa

  output1_path="$TEMP_DIR"/output1.txt
  # shellcheck disable=SC2016
  cat <<-EOF >"$output1_path"
		foo
		$var
		bar
	EOF

  output2_path="$TEMP_DIR"/output2.txt
  cat <<EOF >"$output2_path"
foo
$var
bar
EOF
  assert_eq "$(shasum "$output1_path" | field 1)" "$(shasum "$output2_path" | field 1)"

  output3_path="$TEMP_DIR"/output3.txt
  here_doc_107d344 "$var" >"$output3_path"
  assert_eq "$(shasum "$output1_path" | field 1)" "$(shasum "$output3_path" | field 1)" 
)

# # dash annd ash does not support
# test_for_loop() (
#   set -o errexit
# 
#   for ((i = 0; i < 3; i++))
#   do
#     echo "d: $i"
#   done
# )

# # dash does not support pipefail while ash does.
# test_pipefail() (
#   set -o errexit
# 
#   # set -o pipefail
#   false | true
# )

# Bash POSIX mode does not support `echo -n`. While ash, dash do.
# test_echo_n() (
#   set -o errexit
# 
#   output1_path="$TEMP_DIR"/output1.txt
#   echo -n "foo" >"$output1_path"
#   output2_path="$TEMP_DIR"/output2.txt
#   printf "%s" "foo" >"$output2_path"
#   assert_eq "$(shasum "$output1_path" | field 1)" "$(shasum "$output2_path" | field 1)"
# )

test_lineno() {
  echo "$LINENO" | grep -q -E '^[0-9]+$'
}

test_trailing_empty_line() {
  local s="$(
    printf "foo%s" \
      "bar" \
      "baz" \
      # nop
    printf "qux"
  )"
  assert_eq "foobarfoobazqux" "$s"
}

test_escape_sequence() {
  assert_eq "foobarbaz" "$(printf "foo\033[01mbar\033[00mbaz\n" | sed -E 's/\x1b\[[0-9;]*[JKmsu]//g')"
}
