#!/bin/sh
# shellcheck disable=SC3043
# vim: tabstop=2 shiftwidth=2 noexpandtab
# -*- mode: sh; tab-width: 2; indent-tabs-mode: t -*-
test "${guard_8842fe8+set}" = set && return 0; guard_8842fe8=x
set -o nounset -o errexit

. ./task-test.lib.sh
. ./assert.lib.sh
. ./task.sh

toupper_4c7e44e() {
  printf "%s" "$1" | tr '[:lower:]' '[:upper:]'
}

tolower_542075d() {
  printf "%s" "$1" | tr '[:upper:]' '[:lower:]'
}

test_ifsv_map() (
  set -o errexit

  assert_eq "FOO,BAR,BAZ," "$(IFS=, ifsv_map "foo,bar,baz," toupper_4c7e44e)"
  assert_eq "FOO,BAR,BAZ," "$(IFS=, ifsv_map "foo,bar,baz," toupper_4c7e44e _)"
  assert_eq "foo,bar,baz," "$(IFS=, ifsv_map "FOO,BAR,BAZ," tolower_542075d)"
  assert_eq "foo,bar,baz," "$(IFS=, ifsv_map "FOO,BAR,BAZ," tolower_542075d _)"
)

test_ifsv_filter() (
  set -o errexit

  assert_eq "foo,bar,baz," "$(IFS=, ifsv_filter "foo,bar,,baz," test -n)"
  assert_eq "foo,bar,baz," "$(IFS=, ifsv_filter "foo,bar,,baz," test -n _)"
  assert_eq "4,5,6,7," "$(IFS=, ifsv_filter "1,2,3,4,5,6,7," test _ -gt 3)"
)

test_ifsv_reduce() (
  set -o errexit

  # shellcheck disable=SC2317
  add() (
    echo $(( $1 + $2 ))
  )

  assert_eq 10 "$(IFS=, ifsv_reduce "1,2,3,4" 0 add)"

  # shellcheck disable=SC1102
  # shellcheck disable=SC2005
  # shellcheck disable=SC2086
  # shellcheck disable=SC2046
  # shellcheck disable=SC2317
  rpn() { echo $(($1 $3 $2)); }
  assert_eq 10 "$(IFS="|" ifsv_reduce "4|3|2|1" 0 rpn _ _ '+')"
  assert_eq 24 "$(IFS="|" ifsv_reduce "4|3|2|1" 1 rpn _ _ '*')"

)

test_version_comparison() (
  set -o errexit

  assert_true version_gt 1.0 0.9
  assert_true version_gt 1.1 1.0
  assert_true version_gt 1.1 1.0.9
  assert_true version_gt 1.1.1 1.1
  assert_true version_gt 1.1.1 1.1.0
  assert_true version_gt 1.1.1 1.1.1-alpha1
  assert_true version_gt v1.5.0-patch v1.5.0
  assert_true version_gt go1.23.2 go1.20.0
  assert_false version_gt 1.0 1.0
  assert_true version_ge 1.0 1.0

  assert_eq "v1,v1.4.3,v1.5.0," "$(IFS=, ifsv_sort "v1.5.0,v1,v1.4.3," sort_version)"
  assert_eq "v1.5.0,v1.4.3,v1," "$(IFS=, ifsv_sort "v1.5.0,v1,v1.4.3," sort_version -r)"

  cat <<EOF > "$(get_temp_dir_path)/versions.txt"
v1.4.0-alpha
v1.4.0-alpha1
v1.4.0-beta
v1.4.0-patch
v1.4.0-patch2
v1.4.0-patch9
v1.4.0-patch10
v1.4.0-rc1
v1.4.0
v1.5
v1.4
v1
v1.5.0-alpha
v1.5.0-alpha2
v1.5.0-alpha1
v1.5.0-beta
v1.5.0-patch
v1.5.0-patch1
v1.5.0-beta2
v1.5.0
EOF
  cat <<EOF > "$(get_temp_dir_path)/expected.txt"
v1
v1.4
v1.4.0-alpha
v1.4.0-alpha1
v1.4.0-beta
v1.4.0-rc1
v1.4.0
v1.4.0-patch
v1.4.0-patch2
v1.4.0-patch9
v1.4.0-patch10
v1.5
v1.5.0-alpha
v1.5.0-alpha1
v1.5.0-alpha2
v1.5.0-beta
v1.5.0-beta2
v1.5.0
v1.5.0-patch
v1.5.0-patch1
EOF
  sort_version <"$(get_temp_dir_path)/versions.txt" >"$(get_temp_dir_path)/actual.txt"
  assert_eq "$(cat "$(get_temp_dir_path)/expected.txt")" "$(cat "$(get_temp_dir_path)/actual.txt")"
)

test_menu_item() (
  set -o errexit

  assert_match ".+S.+ave" "$(menu_item "&Save")"
  assert_match "E.+x.+it" "$(menu_item "E&xit")"
  assert_match "Save & E.+x.+it" "$(menu_item "Save && E&xit")"
  assert_match "   Hello .+I.+ am" "$(menu_item "   Hello &I am")"
  assert_eq "" "$(menu_item "")"
  assert_eq "Exit" "$(menu_item "Exit")"
  # shellcheck disable=SC2016
  assert_match '.+A.+dd \$100' "$(menu_item '&Add $100')"
)

test_field() (
  set -o errexit

  assert_eq "foo" "$(echo "foo bar baz" | field 1)"
  assert_eq "bar" "$(echo "   foo      bar   baz  " | field 2)"
  assert_eq "baz" "$(printf "foo bar\nbaz qux\n" | field 3)"
)

# Test plist functions.
test_plist() (
  set -o errexit

  IFS=,
  csvpl=
  csvpl="$(ifsv_put "$csvpl" "key1" "val1")"
  csvpl="$(ifsv_put "$csvpl" "key2" "val2")"

  assert_eq "key1,key2," "$(ifsv_keys "$csvpl")"
  assert_eq "" "$(ifsv_keys "")"

  assert_eq "val1,val2," "$(ifsv_values "$csvpl")"
  assert_eq "" "$(ifsv_values "")"

  assert_eq "val2" "$(ifsv_get "$csvpl" "key2")"
  assert_false ifsv_get "$csvpl" "key3"

  assert_eq "key1,mod1,key2,val2," "$(ifsv_put "$csvpl" "key1" "mod1")"
  assert_eq "key1,val1,key2,val2,key3,val3," "$(ifsv_put "$csvpl" "key3" "val3")"

  assert_eq "key1,val1,key2,," "$(ifsv_put "$csvpl" "key2" "")"
  assert_eq "" "$(ifsv_get "key1,val1,key2," "key2")"

  assert_eq "key1,val1,key2,val2,,empty," "$(ifsv_put "$csvpl" "" "empty")"
  assert_eq "empty" "$(ifsv_get "key1,val1,key2,val2,,empty" "")"

  IFS="$us"
  usvpl=
  usvpl=$(ifsv_put "$usvpl" "foo bar" "FOO BAR")
  usvpl=$(ifsv_put "$usvpl" "baz qux" "BAZ QUX")
  assert_eq "foo bar${us}FOO BAR${us}baz qux${us}BAZ QUX${us}" "$usvpl"
  assert_eq "BAZ QUX" "$(ifsv_get "$usvpl" "baz qux")"
)

# Split the text.
test_split() (
  set -o errexit

  assert_eq "foo,bar,baz" "$(echo "foo, bar,  baz" | sed -E -e "s/, *"/,/g)"
  assert_eq "foo${us}bar${us}baz" "$(echo "foo, bar,  baz" | sed -E -e "s/, */${us}/g")"
)

# Parse with sed(1) and process the text.
test_sed_usv() (
  set -o errexit

  input_path="$(get_temp_dir_path)/input.txt"
  cat <<'EOF' >"$input_path"
foo bar baz
other lines
123 456 789

hello world
hoge fuga hare
012 345 678 900
EOF
  output_path="$(get_temp_dir_path)/output.txt"
  sed -E \
    -e "s/^([[:alpha:]]{3}) ([[:alpha:]]{3}) ([[:alpha:]]{3})$/case1${us}\1${us}\2${us}\3${us}/" -e t \
    -e "s/^([[:alpha:]]{4}) ([[:alpha:]]{4}) ([[:alpha:]]{4})$/case2${us}\1${us}\2${us}\3${us}/" -e t \
    -e "s/^([[:digit:]]{3}) ([[:digit:]]{3}) ([[:digit:]]{3})$/case3${us}\1${us}\2${us}\3${us}/" -e t \
    -e "s/^(.*)$/nop${us}\1${us}/" <"$input_path" \
  | while IFS= read -r line
  do
    IFS="$us"
    # shellcheck disable=SC2086
    set -- $line
    unset IFS
    op="$1"
    shift
    case "$op" in
      (case1)
        echo "a: $1 $2 $3"
        ;;
      (case2)
        echo "b: $1 $2 $3"
        ;;
      (case3)
        echo "c: $1 $2 $3"
        ;;
      (nop)
        echo "z: $1"
        ;;
      (*)
        echo "Unhandled operation: $op" >&2
        ;;
    esac  
  done >"$output_path"
  
  expected_path="$(get_temp_dir_path)/expected.txt"
  cat <<'EOF' >"$expected_path"
a: foo bar baz
z: other lines
c: 123 456 789
z: 
z: hello world
b: hoge fuga hare
z: 012 345 678 900
EOF

  assert_eq "$(sha1sum "$expected_path" | field 1)" "$(sha1sum "$output_path" | field 1)"
)

# Parse with sed(1) and execute the commands.
test_sed_usv_global() (
  set -o errexit

  input_path="$(get_temp_dir_path)/input.txt"
  cat <<'EOF' >"$input_path"
foo toupper(bar) baz toupper(qux) HOGE tolower(FUGA)
other lines
EOF
  output_path="$(get_temp_dir_path)/output.txt"
  sed -E \
    -e "s/${lwb}toupper${rwb}\(([[:alpha:]]+)\)/${is1}toupper_4c7e44e${is2}\1${is1}/g" \
    -e "s/${lwb}tolower${rwb}\(([[:alpha:]]+)\)/${is1}tolower_542075d${is2}\1${is1}/g" \
    -e "s/^(.*${is1}[[:alnum:]_]+${is2}.*)$/call${is1}\1${is1}/" -e t \
    -e "s/^(.*)$/nop${is1}\1${is1}/" <"$input_path" \
  | while IFS= read -r line
  do
    IFS="$is1"
    # shellcheck disable=SC2086
    set -- $line
    unset IFS
    op="$1"
    shift
    case "$op" in
      (call)
        for arg in "$@"
        do 
          case "$arg" in
            (*${is2}*)
              echo "$arg" | (
                IFS="$is2" read -r cmd param
                "$cmd" "$param"
              )
              ;;
            (*)
              printf "%s" "$arg"
              ;;
          esac
        done
        echo
        ;;
      (nop)
        echo "$1"
        ;;
      (*)
        echo "Unhandled operation: $op" >&2
        ;;
    esac
  done >"$output_path"
  # cat "$output_path" >&2
  expected_path="$(get_temp_dir_path)/expected.txt"
  cat <<'EOF' >"$expected_path"
foo BAR baz QUX HOGE fuga
other lines
EOF
  assert_eq "$(sha1sum "$expected_path" | field 1)" "$(sha1sum "$output_path" | field 1)"
)

# Test IFS push/pop functions.
test_ifs() (
  set -o errexit

  unset IFS

  push_ifs
  IFS=,
  assert_eq "," "$IFS"

  push_ifs
  IFS=:
  assert_eq ":" "$IFS"

  pop_ifs
  assert_eq "," "$IFS"

  pop_ifs
  assert_true test "${IFS+set}" != set
)

test_extra() (
  skip_unless_all

  echo "Executed extra test." >&2
)

test_not_existing_task() (
  assert_false "$SH" task.sh not_existing_task
  "$SH" task.sh --ignore-missing not_existing_task 2>&1 | grep "Unknown task"
  "$SH" task.sh --skip-missing not_existing_task
)

test_dumper() (
  result="$(echo hello | hex_dump | hex_restore)"
  assert_eq "hello" "$result"
  result="$(echo hello2 | oct_dump | oct_restore)"
  assert_eq "hello2" "$result"
)
