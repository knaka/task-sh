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

task_install() { # Install in each directory.
  cd "$script_dir_path" || exit 1
  for dir in "$script_dir_path"/*
  do
    if test -d "$dir"
    then
      (cd "$dir" && sh ./task.sh install)
    fi
  done
}

task_client__build() { # [args...] Build client.
  printf "Building client: "
  delim=""
  for arg in "$@"
  do
    printf "%s%s" "$delim" "$arg"
    delim=", "
  done
  echo
}

task_client__deploy() { # [args...] Deploy client.
  printf "Deploying client: "
  delim=""
  for arg in "$@"
  do
    printf "%s%s" "$delim" "$arg"
    delim=", "
  done
  echo
}

task_git() { # [args...] Run git command.
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

task_task_cmd__copy() { # Copy task.cmd to each directory.
  cd "$script_dir_path" || exit 1
  for dir in *
  do
    if ! test -d "$dir"
    then
      continue
    fi
    cp -f task.cmd "$dir"/task.cmd
  done
}

task_pwd() {
  echo "pwd: $(pwd)"
  exit 0
}

task_fail() { # Fails.
  echo FAIL
  exit 1
}

task_nop() { # Do nothing.
  echo NOP
}
