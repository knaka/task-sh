#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_83631d0-false}" && return 0; sourced_83631d0=true

map="foo,FOO,bar,BAR,"
saved_ifs="$IFS"; IFS=","
# shellcheck disable=SC2086
set -- $map
IFS="$saved_ifs"
while test $# -gt 0
do
  test "$1" = "foo" && val="$2" && break
  shift 2
done
if test $# -eq 0
then
  echo Not found >&2
  exit 1
fi
echo "$val"
