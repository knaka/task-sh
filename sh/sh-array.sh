#!/bin/sh
set -o nounset -o errexit

test "${guard_c5aa5fa+set}" = set && return 0; guard_c5aa5fa=x

. ./task.sh
. ./array.lib.sh
. ./assert.lib.sh

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
set_ifs_comma
for i in $csv_words
do
  result="$result$delim$(toupper "$i")"
  delim=,
done
restore_ifs

assert_eq "HELLO,WORLD,FOO,,,BAR,BAZ" "$result"

# --------------------------------------------------------------------------

assert_eq "foo,bar,baz" "$(array_filter "foo,,bar,baz" , test -n _)"

greater_than_3() {
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
  echo "${#1}"
}

assert_eq "5,3,7" "$(array_map "Alice,Bob,Charlie" , strlen)"

assert_eq 'Hello, Alice!!!
Hello, Bob!!!
Hello, Charlie!!!' "$(array_each "Alice,Bob,Charlie" , printf "Hello, %s%s\n" _ "!!!")"
