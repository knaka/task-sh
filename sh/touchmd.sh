#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_71b8827-false}" && return 0; sourced_71b8827=true
set -o nounset -o errexit

set -- "$PWD" "${0%/*}" "$@"; test "$2" != "$0" && cd "$2"
. ./task.sh
. ./rand7.sh
. ./datetime-rfc.sh
cd "$1"; shift 2

force=false
OPTIND=1; while getopts f-: OPT
do
  if test "$OPT" = "-"
  then
    OPT="${OPTARG%%=*}"
    # shellcheck disable=SC2030
    OPTARG="${OPTARG#"$OPT"}"
    OPTARG="${OPTARG#=}"
  fi
  case "$OPT" in
    (f|force) force=true;;
    (\?) usage; exit 2;;
    (*) echo "Unexpected option: $OPT" >&2; exit 2;;
  esac
done
shift $((OPTIND-1))

if ! test "${1+set}" = set
then
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
	cat <<-EOF
		---
		Id: $(rand7)
		Title: Memo
		Tags:
		CreatedAtRfc: $(datetime_rfc)
		---

		← <!-- mdpplink href=../README.md -->[Memo](../README.md)<!-- /mdpplink -->

		<!-- mdppindex pattern=*.md -->
		<!-- /mdppindex -->

		---

EOF
done
