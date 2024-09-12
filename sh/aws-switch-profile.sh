#!/bin/sh
set -o nounset -o errexit

if test "${1+SET}" = "SET"
then
  profile="$1"
else
  unset="<UNSET>"
fi

echo "$profile"
