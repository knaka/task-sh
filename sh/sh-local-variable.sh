#!/bin/sh
set -o nounset -o errexit

unset arg
for arg in 1 2 3
do
  echo "arg: $arg"
done
echo d: $arg

global_arg=123

subshell_foo() {
  (
    unset arg
    # shellcheck disable=SC2030
    for arg in 3 4 5
    do
      echo "arg: $arg"
    done
    echo d: $arg
  )
}

{
  global_arg=789
}

echo global_arg: $global_arg

subshell_foo
# shellcheck disable=SC2031
echo d: $arg

subshell_fail() {
  (
    # The subshell fails.s
    # exit 1
    # “return” also works.
    return 1
  )
}

if subshell_fail
then
  echo 04e14ed
else
  echo 0710833
fi

inlineshell_fail() {
  # This exists the script.
  # exit 1
  return 1
}

if inlineshell_fail
then
  echo 0edd89e
else
  echo efccf24
fi

sum1=0

func_foo() {
  # Use and save the positional parameters before setting new ones.
  # ...
  IFS=$(printf '\n\b')
  # shellcheck disable=SC2046
  set -- $(
    for _arg in "$@"
    do
      echo 7aacecb: "$_arg" >&2
    done
    value1=0
    value2=0
    for arg in 100 200 300
    do
      value1=$((value1 + arg))
    done
    for arg in 400 500 600
    do
      value2=$((value2 + arg))
    done
    echo "value1: ${value1}"
    echo "value2: ${value2}"
  )
  unset IFS
  sum1="$1"
  sum2="$2"
}

func_foo aaa bbb
echo sum1: "$sum1"
echo sum2: "$sum2"

echo args: "$@"

v="$(echo "foo bar|bar baz")"
echo 594a1f1: "$v"
IFS="|"
set -- $v
for arg in "$@"
do
  echo 2736b4f: "$arg"
done
