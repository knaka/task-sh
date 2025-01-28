#!/bin/sh
test "${guard_127250c+set}" = set && return 0; guard_127250c=-
set -o nounset -o errexit

foo() {
  x=$(
    seq 10 | while read -r i
    do
      echo d: "$i" >&2
      if test "$i" = 5
      then
        echo Found >&2
        echo "$i"
        break
      fi
    done
  )
  if test -n "$x"
  then
    echo Found: "$x"
    exit 0
  else
    echo Not found
  fi
  echo This should not be printed.
}

foo

