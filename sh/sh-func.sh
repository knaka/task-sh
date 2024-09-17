#!/bin/sh
set -o nounset -o errexit

foo() {
  set -- *.sh
  for arg in "$@"
  do
    echo "8647bb1: $arg"
  done
}

for arg in "$@"
do
  echo 3db8d0c: "$arg"
done

foo

for arg in "$@"
do
  echo f1c5a18: "$arg"
done
