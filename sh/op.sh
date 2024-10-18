#!/bin/sh
set -o errexit -o nounset

if type Powershell > /dev/null 2>&1
then
  exec Powershell -Command "Start-process" "$@"
elif type open > /dev/null 2>&1
then
  exec open "$@"
elif type xdg-open > /dev/null 2>&1
then
  exec xdg-open "$@"
elif type cygstart > /dev/null 2>&1
then
  exec cygstart "$@"
elif type start > /dev/null 2>&1
then
  exec start "$@"
elif type gnome-open > /dev/null 2>&1
then
  exec gnome-open "$@"
elif type kde-open > /dev/null 2>&1
then
  exec kde-open "$@"
elif type xdg-open > /dev/null 2>&1
then
  exec xdg-open "$@"
else
  echo "No command found to open the file."
  exit 1
fi
