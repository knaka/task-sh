#!/bin/sh
set -o nounset -o errexit

test "${guard_8842fe8+set}" = set && return 0; guard_8842fe8=x

. ./assert.lib.sh
. ./task.sh

test_first() (
  set -o errexit

  :
)

test_second() (
  set -o errexit

  :
)

test_array() (
  set -o errexit

  csv_words="hello,world,foo,,,bar,baz"

  # --------------------------------------------------------------------------

  assert_eq "foo" "$(array_head "foo,bar,baz" ,)"
  if array_head "" ,
  then
    echo "array_first failed to return false for an empty list" >&2
    exit 1
  fi

  assert_eq "bar,baz" "$(array_tail "foo,bar,baz" ,)"
  if array_tail "" ,
  then
    echo "array_tail failed to return false for an empty list" >&2
    exit 1
  fi

  assert_eq 3 "$(array_length "foo,bar,baz" ,)"
  assert_eq 0 "$(array_length "" ,)"

  assert_eq "foo,bar,baz" "$(array_append "foo,bar" , baz)"
  assert_eq "foo,bar,baz,qux" "$(array_append "foo,bar" , baz qux)"
  assert_eq "foo,bar,baz,qux" "$(array_append "foo,bar" , "baz,qux")"

  assert_eq "foo,bar,baz" "$(array_prepend "bar,baz" , foo)"
  assert_eq "foo,bar,baz,qux" "$(array_prepend "baz,qux" , foo bar)"
  assert_eq "foo,bar,baz,qux" "$(array_prepend "baz,qux" , "foo,bar")"

  # Stack operations.
  stack="bar,baz"
  stack="$(array_prepend "$stack" , foo)"
  assert_eq "foo,bar,baz" "$stack"
  item="$(array_head "$stack" ,)"
  stack="$(array_tail "$stack" ,)"
  assert_eq "foo" "$item"
  assert_eq "bar,baz" "$stack"

  assert_eq "bar" "$(array_at "foo,bar,baz" , 1)"
  if array_at "foo,bar,baz" , 3
  then
    echo "array_at failed to return false for an out-of-bounds index" >&2
    exit 1
  fi
  if array_at "" , 0
  then
    echo "array_at failed to return false for an empty list" >&2
    exit 1
  fi

  assert_eq "baz,bar,foo" "$(array_reverse "foo,bar,baz" ,)"

  assert_true array_contains 'foo,bar,baz' , foo
  assert_false array_contains 'foo,bar,baz' , qux

  # --------------------------------------------------------------------------

  assert_eq "HELLO,WORLD,FOO,,,BAR,BAZ" "$(
    # shellcheck disable=SC2317
    toupper() { echo "$1" | tr '[:lower:]' '[:upper:]'; }
    array_map "$csv_words" "," toupper
  )"

  # If `-` is passed as the list, then the items are read from stdin.
  assert_eq "FOO,,BAR,BAZ" "$(echo "foo,,bar,baz" | array_map - "," tr '[:lower:]' '[:upper:]')"

  toupper() {
    echo "$1" | tr '[:lower:]' '[:upper:]'
  }

  result=
  delim=
  ifs_comma
  for i in $csv_words
  do
    result="$result$delim$(toupper "$i")"
    delim=,
  done
  ifs_restore

  assert_eq "HELLO,WORLD,FOO,,,BAR,BAZ" "$result"

  # --------------------------------------------------------------------------

  assert_eq "foo,bar,baz" "$(array_filter "foo,,bar,baz" , test -n _)"

  greater_than_3() {
    # shellcheck disable=SC2317
    test "$1" -gt 3
  }

  assert_eq "4 5 6 7" "$(array_filter "1 2 3 4 5 6 7" " " greater_than_3)"

  assert_eq "4 5 6 7" "$(array_filter "1 2 3 4 5 6 7" " " test _ -gt 3)"

  assert_eq "4 5 6 7" "$(
    # shellcheck disable=SC2317
    gt3() { test "$1" -gt 3; }
    array_filter "1 2 3 4 5 6 7" " " gt3
  )"

  add() (
    echo $(( $1 + $2 ))
  )

  assert_eq 3 "$(add 1 2)"
  assert_eq 10 "$(array_reduce "1,2,3,4" "," 0 add)"

  # shellcheck disable=SC1102
  # shellcheck disable=SC2005
  # shellcheck disable=SC2086
  # shellcheck disable=SC2046
  # shellcheck disable=SC2317
  rpn() { echo $(($1 $3 $2)); }
  assert_eq 10 "$(array_reduce "4|3|2|1" "|" 0 rpn _ _ '+')"
  assert_eq 24 "$(array_reduce "4|3|2|1" "|" 1 rpn _ _ '*')"

  assert_eq 24 "$(
    # shellcheck disable=SC2317
    _206d735() (echo $(( $1 * $2 )))
    array_reduce "1,2,3,4" "," 1 _206d735
  )"

  psv_reduce() (
    psv="$1"
    shift
    init="$1"
    shift
    array_reduce "$psv" "|" "$init" "$@"
  )

  psv="100|200|300|400"

  assert_eq 1000 "$(psv_reduce "$psv" 0 rpn _ _ '+')"

  strlen() {
    # shellcheck disable=SC2317
    echo "${#1}"
  }

  assert_eq "5,3,7" "$(array_map "Alice,Bob,Charlie" , strlen)"

  # ?
  # assert_eq 'Hello, Alice!!!
  # Hello, Bob!!!
  # Hello, Charlie!!!' "$(array_each "Alice,Bob,Charlie" , printf "Hello, %s%s\n" _ "!!!")"

  assert_eq "abc,abcde,def,xyz" "$(array_sort "abcde,abc,xyz,def" ,)"
  assert_eq "xyz,def,abcde,abc" "$(array_sort "abcde,abc,xyz,def" , sort -r)"
  array_sort "abcde,abc,xyz,def" , sort_random
)

test_ifs() (
  set -o errexit

  IFS='xyz'
  default_ifs="$IFS"
  ifs_null
  assert_eq "$IFS" ''
  ifs_restore

  assert_eq "$IFS" "$default_ifs"
  ifs_pipe
  assert_eq "$IFS" '|'
  ifs_comma
  assert_eq "$IFS" ','
  ifs_null
  assert_eq "$IFS" ''
  ifs_path_list_sepaprator
  assert_eq "$IFS" ':'
  ifs_restore
  assert_eq "$IFS" ''
  ifs_restore
  assert_eq "$IFS" ","
  ifs_restore
  assert_eq "$IFS" '|'
  ifs_restore
  assert_eq "$IFS" "$default_ifs"

  ifs_newline
  # shellcheck disable=SC2046
  set -- $(printf "hoge fuga\nfoo bar\n")
  assert_eq 2 "$#"
  ifs_restore

  lines="$(
    echo "hoge fuga"
    echo "foo bar"
  )"
  num_lines=$(echo "$lines" | wc -l | (read -r num; echo "$num"))
  assert_true test 2 -eq "$num_lines"

  ifs_default
  lines="$(
    echo "  hoge fuga"
    echo "foo bar  "
  )"
  ifs_newline
  # shellcheck disable=SC2086
  set -- $lines
  ifs_restore
  assert_eq 2 "$#"
)

test_strjoin() (
  set -o errexit

  assert_eq "hoge,fuga,,,foo,bar" "$(array_join "hoge|fuga|||foo|bar" "|" ,)"
  assert_eq "" "$(array_join "" "|" ,)"
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

  assert_eq "v1,v1.4.3,v1.5.0" "$(array_sort "v1.5.0,v1,v1.4.3" , sort_version)"
  assert_eq "v1.5.0,v1.4.3,v1" "$(array_sort "v1.5.0,v1,v1.4.3" , sort_version -r)"

  cat <<EOF > "$(temp_dir_path)/versions.txt"
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
  cat <<EOF > "$(temp_dir_path)/expected.txt"
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
  sort_version < "$(temp_dir_path)/versions.txt" > "$(temp_dir_path)/actual.txt"
  assert_eq "$(cat "$(temp_dir_path)/expected.txt")" "$(cat "$(temp_dir_path)/actual.txt")"
)

test_newline_sep() (
  set -o errexit

  mkdir -p "$(temp_dir_path)/foo/bar baz"
  mkdir -p "$(temp_dir_path)/foo/hoge fuga"
  ifs_null
  # shellcheck disable=SC2046
  set -- hoge fuga $(find "$(temp_dir_path)"/foo/* -type d)
  ifs_restore
  for arg in "$@"
  do
    echo "d: $arg" >&2
  done
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

toupper_4c7e44e() {
  echo "$1" | tr '[:lower:]' '[:upper:]'
}

# shellcheck disable=SC2016
test_eval_with_subst() (
  set -o errexit

  assert_eq '  foo BAR $baz ` $$ QUX' "$(eval_with_subst '  foo toupper(bar) $baz ` $$ toupper(qux)' 's/'"$lwb"'toupper\(([[:alpha:]]+)\)/"$(toupper_4c7e44e "\1")"/g')"
  assert_eq '$`"\; replaced:bar bar  "' "$(eval_with_subst '$`"\; foo bar  "' 's/foo/"$(echo replaced:bar)"/g')"

  input_path="$(temp_dir_path)/input.txt"
  cat <<'EOF' >"$input_path"
foo toupper(bar) baz ` $ "
toupper(hoge) fuga toupper(hare)
EOF
  expected_path="$(temp_dir_path)/expected.txt"
  cat <<'EOF' >"$expected_path"
foo BAR baz ` $ "
HOGE fuga HARE
EOF
  output_path="$(temp_dir_path)/output.txt"
  eval_with_subst_stdin 's/'"$lwb"'toupper\(([[:alpha:]]+)\)/"$(toupper_4c7e44e "\1")"/g' <"$input_path" >"$output_path"
  assert_eq "$(sha1sum "$expected_path" | field 1)" "$(sha1sum "$output_path" | field 1)"
)

test_field() (
  set -o errexit

  assert_eq "foo" "$(echo "foo bar baz" | field 1)"
  assert_eq "bar" "$(echo "   foo      bar   baz  " | field 2)"
  assert_eq "baz" "$(printf "foo bar\nbaz qux\n" | field 3)"
)

test_array_new() (
  set -o errexit

  delim="$unit_sep"
  a=
  a="$(array_append "$a" "$delim" foo bar baz)"
  ifs_us
  for arg in $a
  do
    echo "arg: $arg" >&2
  done
  ifs_restore
)
