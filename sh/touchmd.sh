#!/bin/sh
set -o nounset -o errexit

test "${guard_b125644+set}" = set && return 0; guard_b125644=x

. "$(dirname "$0")"/task.sh
. "$(dirname "$0")"/rand7.sh
. "$(dirname "$0")"/date-rfc3339.sh

force=false
while getopts f-: OPT
do
  if test "$OPT" = "-"
  then
    OPT="${OPTARG%%=*}"
    # shellcheck disable=SC2030
    OPTARG="${OPTARG#"$OPT"}"
    OPTARG="${OPTARG#=}"
  fi
  case "$OPT" in
    f|force) force=true;;
    \?) usage; exit 2;;
    *) echo "Unexpected option: $OPT" >&2; exit 2;;
  esac
done
shift $((OPTIND-1))

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
	elif test -e "$file" && ! $force
	then
		echo "$file exists. Just touching." >&2
		touch "$file"
		continue
	else
		exec 1>"$file"
	fi
	utc_datetime_rfc3339="$(date_rfc3339)"
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
