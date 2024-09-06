#!/bin/sh
set -o nounset -o errexit

script_dir_path="$(dirname "$0")"
cd "$script_dir_path"

_set_path_attr() {
  _979089b_path="$1"
  _5d3b4b2_attribute="$2"
  _5367958_value="$3"
  if which xattr > /dev/null 2>&1
  then
    xattr -w "$_5d3b4b2_attribute" "$_5367958_value" "$_979089b_path"
  elif which attr > /dev/null 2>&1
  then
    attr -s "$_5d3b4b2_attribute" -V "$_5367958_value" "$_979089b_path"
  elif which PowerShell > /dev/null 2>&1
  then
    PowerShell -Command "Set-Content -Path '$_979089b_path' -Stream '$_5d3b4b2_attribute' -Value '$_5367958_value'"
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

script_dir_path="$(dirname "$0")"
if test "${1+SET}" != "SET"
then
  exit 1
fi
subcmd="$1"
shift
case "$subcmd" in
  install)
    for dir in "$script_dir_path"/*
    do
      if test -d "$dir"
      then
        (cd "$dir" && sh ./task.sh install)
      fi
    done
    ;;
  git)
    cd "$script_dir_path"
    if ! test -d .git
    then
      git init
      set_path_sync_ignored .git/
      git remote add origin git@github.com:knaka/scr.git
      git branch --set-upstream-to=origin/main main
      git fetch origin
    fi
    exec git "$@"
    ;;
  copy-task-cmd)
    cd "$script_dir_path"
    for dir in *
    do
      if ! test -d "$dir"
      then
        continue
      fi
      cp -f task.cmd "$dir"/task.cmd
    done
    ;;
  nop)
    echo NOP
    ;;
  *)
    exit 1
    ;;
esac
