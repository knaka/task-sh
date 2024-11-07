#!/bin/sh
test "${guard_a1f7080+set}" = set && return 0; guard_a1f7080=x
set -o nounset -o errexit

s="foo:bar bar:baz"

IFS=: read -r a b c <<EOF
$s
EOF
echo a: "$a"
echo b: "$b"
echo c: "$c"

echo

IFS=:
# shellcheck disable=SC2086
set -- $s
echo a: "$1"
echo b: "$2"
echo c: "$3"
unset IFS

echo


