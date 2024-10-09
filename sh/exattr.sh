#!/bin/sh
set -o nounset -o errexit

test "${guard_c877466+set}" = set && return 0; guard_c877466=x

. "$(dirname "$0")"/task.sh

if is_windows
then
  for path in "$@"
  do
    if ! test -e "$path"
    then
      echo "No such file or directory: $path" >&2
      continue
    fi
    path="$(realpath "$path")"
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
  done
  exit 0
fi

if type xattr > /dev/null 2>&1
then
  xattr "$@"
  exit 0
elif type getfattr > /dev/null 2>&1
then
  getfattr -d -m - "$@"
  exit 0
else
  echo "No extended attributes support." >&2
  exit 1
fi
