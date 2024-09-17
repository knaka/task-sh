#!/bin/sh
set -o nounset -o errexit

is_windows() {
  case "$(uname -s)" in
    Windows_NT|CYGWIN*|MINGW*|MSYS*) return 0 ;;
    *) return 1 ;;
  esac
}

_set_path_attr() {
  __path="$1"
  __attribute="$2"
  __value="$3"
  if which xattr > /dev/null 2>&1
  then
    xattr -w "$__attribute" "$__value" "$__path"
  elif which attr > /dev/null 2>&1
  then
    attr -s "$__attribute" -V "$__value" "$__path"
  elif which PowerShell > /dev/null 2>&1
  then
    PowerShell -Command "Set-Content -Path '$__path' -Stream '$__attribute' -Value '$__value'"
  fi
}

attributes="com.dropbox.ignored com.apple.fileprovider.ignore#P"

set_path_sync_ignored() {
  for _path in "$@"
  do
    for _attribute in $attributes
    do
      _set_path_attr "$_path" "$_attribute" 1
    done
  done
}

is_newer_than() {
  test -n "$(find "$1" -newer "$2"  2>/dev/null)" || return 1
}
