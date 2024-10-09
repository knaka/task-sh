#!/bin/sh
set -o nounset -o errexit

test "${guard_c877466+set}" = set && return 0; guard_c877466=x

. "$(dirname "$0")"/task.sh

if is_windows
then
  path="$(realpath "$1")"
  for attrib in $file_sharing_ignorance_attributes
  do
    # Remove trailing backslashes.
    printf "%s:%s " "$path" "$attrib":
    if PowerShell.exe -Command "Get-Content $path:$attrib" > /dev/null 2>&1
    then
      PowerShell.exe -Command "Get-Content $path:$attrib"
    else
      echo "-"
    fi
  done
  exit 0
fi

if type xattr > /dev/null 2>&1
then
  xattr "$1"
  exit 0
elif type getfattr > /dev/null 2>&1
then
  getfattr -d -m - "$1"
  exit 0
else
  echo "No extended attributes support." >&2
  exit 1
fi
