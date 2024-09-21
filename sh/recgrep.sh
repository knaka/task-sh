#!/bin/sh
set -o nounset -o errexit

globbing_pattern=
len="$#"
i=1
for arg in "$@"
do

  if test "$i" -eq "$len"
  then
    globbing_pattern="$arg"
  shift
    break
  fi
  set -- "$@" "$arg"
  shift
  i=$((i + 1))
done

# Busybox's find(1) seems not working with symbolic links.
cd "$(realpath .)"
find . -type f -name "$globbing_pattern" -exec grep "$@" {} \+
