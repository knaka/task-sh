#!/bin/sh
set -o nounset -o errexit

# Set this script output to the AWS_PROFILE environment variable.

if test "${1+SET}" = "SET"
then
  profile="$1"
else
  unset="<UNSET>"
  profiles="$(sed -n -r -e 's/\[(profile )?(.*)\]/\2/p' < "$HOME"/.aws/config)"
  profiles="$(printf "%s\n%s" "$unset" "$profiles")"
  i=0
  if test "${AWS_PROFILE+SET}" = "SET"
  then
    for profile in $profiles
    do
      if test "$profile" = "$AWS_PROFILE"
      then
        break
      fi
      i=$((i + 1))
    done
  fi
  profile=$(echo "$profiles" | peco --initial-index="$i")
  if test "$profile" = "$unset"
  then
    exit 0
  fi
fi
echo "$profile"
