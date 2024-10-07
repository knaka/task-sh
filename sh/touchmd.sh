#!/bin/sh
set -o nounset -o errexit

test "${guard_b125644+set}" = set && return 0; guard_b125644=x

. "$(dirname "$0")"/rand7.sh

if ! test "${1+set}" = set
then
	echo 59d3089 >&2
	set -- -
fi

for file in "$@"
do
	if test "$file" = -
	then
		:
	elif test -e "$file"
	then
		echo "$file exists. Just touching." >&2
		touch "$file"
		continue
	else
		exec 1>"$file"
	fi
	utc_datetime_rfc3339="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
	cat <<-EOF
		---
		Id: $(rand7)
		Title: Memo
		Tags:
		CreatedAtRfc3339: $utc_datetime_rfc3339
		---

		← <!-- mdpplink href=../README.md -->[Memo](../README.md)<!-- /mdpplink -->

		<!-- mdppindex pattern=*.md -->
		<!-- /mdppindex -->

		---

EOF
done
