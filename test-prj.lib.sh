#!/bin/sh
set -o nounset -o errexit

test "${guard_8842fe8+set}" = set && return 0; guard_8842fe8=x

. ./assert.lib.sh
. ./task.sh

test_array() (
  set -o errexit

  csv_words="hello,world,foo,,,bar,baz,"

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
  assert_eq "foo,bar,baz," "$(array_append "foo,bar,baz" , "")"
  a="$(array_append "foo,bar,baz" , "")"
  # assert_eq 4 "$(array_length "$a" ,)"

  assert_eq "foo,bar,baz" "$(array_prepend "bar,baz" , foo)"
  assert_eq "foo,bar,baz,qux" "$(array_prepend "baz,qux" , foo bar)"
  assert_eq "foo,bar,baz,qux" "$(array_prepend "baz,qux" , "foo,bar")"
  assert_eq ",foo,bar,baz" "$(array_prepend "foo,bar,baz" , "")"

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

  IFS=aaa
  default_ifs="$IFS"
  ifs_pipe
  assert_eq "$IFS" '|'
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
  # printf '%s' "$IFS" | dm
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
  sort_version <"$(temp_dir_path)/versions.txt" >"$(temp_dir_path)/actual.txt"
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
  printf "%s" "$1" | tr '[:lower:]' '[:upper:]'
}

tolower_542075d() {
  printf "%s" "$1" | tr '[:upper:]' '[:lower:]'
}

test_field() (
  set -o errexit

  assert_eq "foo" "$(echo "foo bar baz" | field 1)"
  assert_eq "bar" "$(echo "   foo      bar   baz  " | field 2)"
  assert_eq "baz" "$(printf "foo bar\nbaz qux\n" | field 3)"
)

test_unit_sep() (
  set -o errexit

  usv_items=
  usv_items="$(array_append "$usv_items" "$unit_sep" foo bar baz)"
  usv_items="$(array_append "$usv_items" "$unit_sep" "$(printf 'hoge\nfuga\n')" 'hare')"
  assert_eq 5 "$(array_length "$usv_items" "$unit_sep")"
  ifs_unit_sep
  for arg in $usv_items
  do
    (
      ifs_restore
      echo "arg: $arg" >&2
    )
  done
  # shellcheck disable=SC2086
  printf "%s\0" $usv_items | xargs -0 -n1 echo "arg2:"
  ifs_restore

  echo

  usv_upper_items="$(array_map "$usv_items" "$unit_sep" toupper_4c7e44e)"
  ifs_unit_sep
  for arg in $usv_upper_items
  do
    echo "arg3: $arg" >&2
  done
  echo "concat:" "$(array_join "$usv_upper_items" "$unit_sep" '---')"
  ifs_restore
  echo "concat2:" "$(array_reduce "$usv_upper_items" "$unit_sep" '' printf '%s###%s' _ _)"
  # shellcheck disable=SC2317
  contains_hoge() {
    echo "$1" | grep -q -i hoge
  }
  echo "filter:" "$(array_filter "$usv_upper_items" "$unit_sep" contains_hoge)"

  echo

  usv_items="$(array_prepend "$usv_items" "$unit_sep" "$(printf 'aaa\nbbb')")"
  # echo e817d4d: "$usv_items" >&2
  assert_eq 6 "$(array_length "$usv_items" "$unit_sep")"
  while test "$(array_length "$usv_items" "$unit_sep")" -gt 0
  do
    item="$(array_head "$usv_items" "$unit_sep")"
    usv_items="$(array_tail "$usv_items" "$unit_sep")"
    echo "item: $item" >&2
  done
)

test_array_renew() (
  set -o errexit

  assert_eq 0 "$(array_length "" ,)"
  assert_eq "," "$(array_append "" , "")"
  assert_eq "," "$(array_prepend "" , "")"

  assert_eq 1 "$(array_length "," ,)"
  assert_eq "" "$(array_head "," ,)"
  assert_eq "" "$(array_tail "," ,)"
  assert_eq ",foo" "$(array_append "," , "foo")"
  assert_eq "foo,," "$(array_prepend "," , "foo")"
  assert_eq "" "$(array_head "," , "")"
  assert_eq "" "$(array_tail "," ,)"

  assert_eq 2 "$(array_length ",," ,)"
  assert_eq ",,foo" "$(array_append ",," , "foo")"
  assert_eq "foo,,," "$(array_prepend ",," , "foo")"
  assert_eq ",,," "$(array_prepend ",," , "")"
  assert_eq "" "$(array_head ",," ,)"
  assert_eq "," "$(array_tail ",," ,)"
  assert_eq "foo" "$(array_tail ",foo" ,)"

  assert_eq 1 "$(array_length "foo" ,)"
  assert_eq 1 "$(array_length "foo," ,)"
  assert_eq 2 "$(array_length "foo,bar" ,)"
  assert_eq 2 "$(array_length "foo,bar," ,)"

  csv_items=",foo,bar,"
  count=0
  ifs_comma
  # shellcheck disable=SC2046
  for item in $csv_items
  do
    echo "item: $item" >&2
    count=$((count + 1))
  done
  ifs_restore
  assert_eq 3 "$count"

  csv_items=",foo,bar"
  ifs_comma
  count=0
  # shellcheck disable=SC2046
  for item in $csv_items
  do
    echo "item: $item" >&2
    count=$((count + 1))
  done
  ifs_restore
  assert_eq 3 "$count"

  assert_eq "foo,bar" "$(array_slice "foo,bar,baz" , 0 2)"
  assert_eq "bar,baz" "$(array_slice "foo,bar,baz" , 1 3)"
  assert_eq "foo,bar,baz" "$(array_slice "foo,bar,baz" , 0)"
  assert_eq "bar,baz" "$(array_slice "foo,bar,baz" , 1)"

  assert_eq "foo,qux,baz" "$(array_at "foo,bar,baz" , 1 qux)"
  assert_false array_at "foo,bar,baz" , 3
  assert_false array_at "foo,bar,baz" , 3 value
)

test_plist() (
  set -o errexit

  plist=
  plist="$(plist_put "$plist" , "key1" "val1")"
  plist="$(plist_put "$plist" , "key2" "val2")"

  assert_eq "key1,key2" "$(plist_keys "$plist" ,)"
  assert_eq "" "$(plist_keys "" ,)"

  assert_eq "val1,val2" "$(plist_values "$plist" ,)"
  assert_eq "" "$(plist_values "" ,)"

  assert_eq "val2" "$(plist_get "$plist" , "key2")"
  assert_false plist_get "$plist" , "key3"

  assert_eq "key1,mod1,key2,val2" "$(plist_put "$plist" , "key1" "mod1")"
  assert_eq "key1,val1,key2,val2,key3,val3" "$(plist_put "$plist" , "key3" "val3")"

  assert_eq "key1,val1,key2," "$(plist_put "$plist" , "key2" "")"
  assert_eq "" "$(plist_get "key1,val1,key2," , "key2")"

  assert_eq "key1,val1,key2,val2,,empty" "$(plist_put "$plist" , "" "empty")"
  assert_eq "empty" "$(plist_get "key1,val1,key2,val2,,empty" , "")"

  plist2=
  plist2=$(plist_put "$plist2" "$unit_sep" "foo bar" "FOO BAR")
  plist2=$(plist_put "$plist2" "$unit_sep" "baz qux" "BAZ QUX")
  assert_eq "foo bar${unit_sep}FOO BAR${unit_sep}baz qux${unit_sep}BAZ QUX" "$plist2"
  assert_eq "BAZ QUX" "$(plist_get "$plist2" "$unit_sep" "baz qux")"
)

test_split() (
  set -o errexit

  assert_eq "foo,bar,baz" "$(array_string_split , "foo, bar,  baz" ", *")"
  assert_eq "foo${unit_sep}bar${unit_sep}baz" "$(array_string_split "$unit_sep" "foo, bar,  baz" ", *")"
)

test_sed_usv() (
  set -o errexit

  input_path="$(temp_dir_path)/input.txt"
  cat <<'EOF' >"$input_path"
foo bar baz
other lines
123 456 789

hello world
hoge fuga hare
012 345 678 900
EOF
  output_path="$(temp_dir_path)/output.txt"
  sed -E \
    -e "s/^([[:alpha:]]{3}) ([[:alpha:]]{3}) ([[:alpha:]]{3})$/case1${us}\1${us}\2${us}\3${us}/" -e t \
    -e "s/^([[:alpha:]]{4}) ([[:alpha:]]{4}) ([[:alpha:]]{4})$/case2${us}\1${us}\2${us}\3${us}/" -e t \
    -e "s/^([[:digit:]]{3}) ([[:digit:]]{3}) ([[:digit:]]{3})$/case3${us}\1${us}\2${us}\3${us}/" -e t \
    -e "s/^(.*)$/nop:\1${us}/" <"$input_path" \
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
        echo "a: $1 $2 $3" >&2
        ;;
      (case2)
        echo "b: $1 $2 $3" >&2
        ;;
      (case3)
        echo "c: $1 $2 $3" >&2
        ;;
      (nop)
        echo "z: $1" >&2
        ;;
      (*)
        echo "Unhandled operation: $op" >&2
        ;;
    esac  
  done >"$output_path"
  cat "$output_path"
)

# Parse with sed(1) and execute the commands.
test_sed_usv_global() (
  set -o errexit

  input_path="$(temp_dir_path)/input.txt"
  cat <<'EOF' >"$input_path"
foo toupper(bar) baz toupper(qux) HOGE tolower(FUGA)
other lines
EOF
  output_path="$(temp_dir_path)/output.txt"
  sed -E \
    -e "s/${lwb}toupper${rwb}\(([[:alpha:]]+)\)/${us}toupper_4c7e44e:\1${us}/g" \
    -e "s/${lwb}tolower${rwb}\(([[:alpha:]]+)\)/${us}tolower_542075d:\1${us}/g" \
    -e "s/^(.*${us}[[:alnum:]_]+:.*)$/call${us}\1${us}/" -e t \
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
      (call)
        for arg in "$@"
        do 
          case "$arg" in
            (toupper_4c7e44e:*|tolower_542075d:*)
              echo "$arg" | (
                IFS=: read -r cmd param
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
  expected_path="$(temp_dir_path)/expected.txt"
  cat <<'EOF' >"$expected_path"
foo BAR baz QUX HOGE fuga
other lines
EOF
  assert_eq "$(sha1sum "$expected_path" | field 1)" "$(sha1sum "$output_path" | field 1)"
)

