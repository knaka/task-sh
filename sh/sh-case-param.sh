#!/bin/sh
test "${guard_9e9beb6+set}" = set && return 0; guard_9e9beb6=x
set -o nounset -o errexit

. ./task.sh

var="foo${is2}bar${is1}hoge${is2}fuga"

IFS="$is1"
for i in $var
do
  case "$i" in
    *${is2}*)
      IFS="$is2"
      for j in $i
      do
        echo d: "$j"
      done
      ;;
    *)
      exit
      ;;
  esac
done
unset IFS
