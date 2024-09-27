#!/bin/sh
set -o nounset -o errexit

foo() {
  echo "foo"
  pwd
  set -- "$PWD" "$@"
  cd ..
  pwd
  bar
  cd "$1"
  pwd
  shift
}

bar() {
  echo "bar"
}

pwd
set -- "$PWD" "$@"
cd ..
pwd
foo
