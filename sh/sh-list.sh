#!/bin/sh
set -o nounset -o errexit

test "${guard_e98fcbe+set}" = set && return 0; guard_e98fcbe=x

list=

add_item() {
  list="${list:+$list|}$1"
}

add_item "123"
add_item "hello world"
add_item "xyz"
add_item "foo bar"
add_item "abc" 

IFS='|'
for item in $list
do
  echo b3687f9: "$item"
done
unset IFS

echo

(
  IFS='|'
  for item in $list
  do
    echo b141c3f: "$item"
  done
)

echo

for item in $list
do
  echo 4a67923: "$item"
done
