#!/bin/sh
test "${guard_57847e6+set}" = set && return 0; guard_57847e6=x
set -o nounset -o errexit

. ./task.sh

# Fixed length (= tuple).
printf "foo bar\n\nhoge fuga\n" | (
  read -r a
  echo "d0: $a"
  read -r b
  echo "d1: $b"
  read -r c
  echo "d2: $c"
)

# Variable length (= list, = array).
ifs_newline
# shellcheck disable=SC2046
set -- $(printf "foo bar\nbar baz\nhoge fuga\n")
for arg in "$@"
do
  echo "arg0: $arg"
done
ifs_restore

# Not good for blank lines.
ifs_newline
# shellcheck disable=SC2046
set -- $(printf "\nfoo bar\nbar baz\nhoge fuga\n")
test "$#" -eq 3
for arg in "$@"
do
  echo "arg1: $arg"
done
ifs_restore

# You have to user loop for reading lines which can be empty.
# Not to trim leading and trailing spaces.
printf "\nfoo bar\n  bar baz\nhoge fuga\n" | while IFS= read -r arg
do
  echo "arg2: $arg"
done
