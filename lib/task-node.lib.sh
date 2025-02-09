# vim: set filetype=sh :
# shellcheck shell=sh
test "${guard_ca67a57+set}" = set && return 0; guard_ca67a57=true

. ./task.sh
. ./task-volta.lib.sh

subcmd_npm() { # Run npm.
  set_node_env
  invoke npm "$@"
}

subcmd_npx() { # Run npx.
  set_node_env
  invoke npx "$@"
} 

subcmd_node() { # Run Node.js.
  set_node_env
  node"$(exe_ext)" "$@"
}

task_npm__install() { # Install the npm packages if the package.json is modified.
  first_call ac87fe4 || return 0
  ! test -f "$SCRIPT_DIR"/package.json && return 1
  local last_check_path="$SCRIPT_DIR"/node_modules/.npm_last_check
  while true
  do
    ! test -d "$SCRIPT_DIR"/node_modules/ && break
    ! test -f "$SCRIPT_DIR"/package-lock.json && break
    ! test -f "$last_check_path" && break
    newer "$SCRIPT_DIR"/package.json --than "$last_check_path" && break
    newer "$SCRIPT_DIR"/package-lock.json --than "$last_check_path" && break
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
  task_npm__install
  local p="$SCRIPT_DIR"/node_modules/"$pkg"/"$bin_path"
  if test -f "$p" && head -1 "$p" | grep -q '^#!.*node'
  then
    if ! invoke subcmd_node "$p" "$@"
    then
      return $?
    fi
    return 0
  fi
  if is_win
  then
    for ext in .exe .cmd .bat
    do
      if test -f "$p$ext"
      then
        p="$p$ext"
        break
      fi
    done
  fi
  invoke "$p" "$@"
}
