#!/bin/sh
set -o nounset -o errexit

test "${guard_b125644+set}" = set && return 0; guard_b125644=x

test "${1+set}" = set || return 1

file="$1"

if test -r "$file"
then
  touch "$file"
  exit 0
fi

cat <<- EOF > "$file"
	---
	Title: Memo
	---

	← <!-- mdpplink href=../README.md -->[メモ](../README.md)<!-- /mdpplink -->

	<!-- mdppindex pattern=*.md -->
	<!-- /mdppindex -->

	---

EOF
