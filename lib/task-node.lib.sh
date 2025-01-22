#!/bin/sh
set -o nounset -o errexit

test "${guard_ca67a57+set}" = set && return 0; guard_ca67a57=-

. ./task.sh
. ./task-volta.lib.sh

subcmd_npm() { # Run npm.
  set_node_env
  cross_run npm "$@"
}

subcmd_npx() { # Run npx.
  set_node_env
  cross_run npx "$@"
} 

subcmd_node() { # Run Node.js.
  set_node_env
  node"$(exe_ext)" "$@"
}

task_npm__depinstall() { # Install the npm packages if the package.json is modified.
  first_call ac87fe4 || return 0
  ! test -f package.json && return 1
  local last_check_path=node_modules/.npm_last_check
  while true
  do
    ! test -d node_modules/ && break
    ! test -f package-lock.json && break
    ! test -f "$last_check_path" && break
    newer package.json --than "$last_check_path" && break
    newer package-lock.json --than "$last_check_path" && break
    return 0
  done
  echo "Installing npm packages." >&2
  subcmd_npm install
  touch "$last_check_path"
}

run_node_modules_bin() { # Run the bin file in the node_modules.
  local pkg="$1"
  shift
  local bin_path="$1"
  shift
  task_npm__depinstall
  local p=node_modules/"$pkg"/"$bin_path"
  if test -f "$p" && head -1 "$p" | grep -q '^#!.*node'
  then
    subcmd_node "$p" "$@"
    return $?
  fi
  if is_windows
  then
    if test -f "$p".exe
    then
      "$p".exe "$@"
      return $?
    fi
    for ext in .cmd .bat .ps1
    do
      if test -f "$p$ext"
      then
        "$p$ext" "$@"
        return $?
      fi
    done
    return 1
  fi
  "$p" "$@"
}
