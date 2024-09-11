#!/bin/sh
set -o errexit -o nounset

if type Powershell > /dev/null 2>&1
then
  exec Powershell -Command "Start-process" "$@"
fi
