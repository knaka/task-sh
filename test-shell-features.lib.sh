#!/bin/sh
# shellcheck disable=SC3043
test "${guard_82b9af4+set}" = set && return 0; guard_82b9af4=x
set -o nounset -o errexit

. ./assert.lib.sh
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

  output1_path="$(temp_dir_path)/output1.txt"
  # shellcheck disable=SC2016
  cat <<-EOF >"$output1_path"
		foo
		$var
		bar
	EOF

  output2_path="$(temp_dir_path)/output2.txt"
  cat <<EOF >"$output2_path"
foo
$var
bar
EOF
  assert_eq "$(shasum "$output1_path" | field 1)" "$(shasum "$output2_path" | field 1)"

  output3_path="$(temp_dir_path)/output3.txt"
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
#   output1_path="$(temp_dir_path)/output1.txt"
#   echo -n "foo" >"$output1_path"
#   output2_path="$(temp_dir_path)/output2.txt"
#   printf "%s" "foo" >"$output2_path"
#   assert_eq "$(shasum "$output1_path" | field 1)" "$(shasum "$output2_path" | field 1)"
# )

test_lineno() {
  echo 036da98 "$LINENO"
  echo 650a360 "$LINENO"
}

test_printf_q() {
  assert_eq "$(printf "%q" "foo bar \" \nbaz")" "$(printf "foo bar \\\" \\nbaz")"
}