#!/bin/sh

: "${script_dir_path:=}"

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

subcmd_git() { # Run git command.
  cd "$script_dir_path" || exit 1
  if ! test -d .git
  then
    git init
    set_path_sync_ignored .git/
    git remote add origin git@github.com:knaka/scr.git
    git branch --set-upstream-to=origin/main main
    git fetch origin
  fi
  exec git "$@"
}
