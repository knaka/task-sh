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

# # dash and ash does not support
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

# Bash POSIX mode does not support `echo -n`. While ash, dash do. use printf instead.
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
  local s
  s="$(
    printf "foo%s" \
      "bar" \
      "baz" \
      # nop
    printf "qux"
  )"
  assert_eq "foobarfoobazqux" "$s"
}

func_global_ifs() {
  IFS="$newline_char"
  assert_eq "$newline_char" "$IFS"
  # shellcheck disable=SC2046
  set -- $(printf "foo bar\nbar baz\nhoge fuga\n")
  assert_eq $# 3
}

func_local_ifs() {
  local IFS="$newline_char"
  assert_eq "$newline_char" "$IFS"
  # shellcheck disable=SC2046
  set -- $(printf "foo bar\nbar baz\nhoge fuga\n")
  assert_eq $# 3
}

# Test that IFS with local works and does not affects outer scope one.
test_local_ifs() (
  original_ifs="$IFS"
  
  func_global_ifs
  # IFS should still be changed after function returns
  assert_eq "$newline_char" "$IFS"
  
  # Reset for next test
  IFS="$original_ifs"
  
  # Test that local IFS is restored after function returns
  
  func_local_ifs
  # IFS should be restored to original value
  assert_eq "$original_ifs" "$IFS"

  # shellcheck disable=SC2046
  set -- $(printf "foo bar\nbar baz\nhoge fuga\n")
  assert_eq $# 6
)

func_local_readonly() {
  local xad7f9eb
  readonly xad7f9eb=123
}

func_local_readonly_error() {
  local xad7f9eb
  readonly xad7f9eb=123
  xad7f9eb=789
}

test_local_readonly() {
  test "${xad7f9eb+set}" != set
  func_local_readonly
  test "${xad7f9eb+set}" != set
  
  if (func_local_readonly_error)
  then
    echo Should raise readonly error. >&2
    return 1
  fi

  return 0
}
