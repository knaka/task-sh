#!/bin/sh
set -o nounset -o errexit

subcmd_ghcup() { # Run the `ghcup` command.
  exec sh "$(dirname "$0")"/ghcup-cmd.sh "$@"
}

subcmd_stack() { # Run the `stack` command.
  exec sh "$(dirname "$0")"/stack-cmd.sh "$@"
}

task_build() { # Build the project.
  (
    cd "$(dirname "$0")"
    sh stack-cmd.sh build hsprj:main-exe "$@"
    cmd_path="$(sh stack-cmd.sh exec which main-exe)"
    mkdir -p ./build/
    cp -a "$cmd_path" ./build/
    echo Copied the command to: ./build/"$(basename "$cmd_path")" >&2
  )
}

subcmd_run() {
  if ! type "$(dirname "$0")"/build/main-exe > /dev/null 2>&1
  then
    # shellcheck disable=SC2119
    task_build
  fi
  exec "$(dirname "$0")"/build/main-exe "$@"
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

(
  cd "$(dirname "$0")"
  mkdir -p build
  mkdir -p .stack-work
  set_path_sync_ignored build .stack-work
)