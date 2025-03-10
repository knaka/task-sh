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
  invoke node "$@"
}

subcmd_npm__install() { # Install the npm packages if the package.json is modified.
  first_call ac87fe4 || return 0
  ! test -f "$TASKS_DIR"/package.json && return 1
  local last_check_path="$TASKS_DIR"/node_modules/.npm_last_check
  while true
  do
    ! test -d "$TASKS_DIR"/node_modules/ && break
    ! test -f "$TASKS_DIR"/package-lock.json && break
    ! test -f "$last_check_path" && break
    newer "$TASKS_DIR"/package.json --than "$last_check_path" && break
    newer "$TASKS_DIR"/package-lock.json --than "$last_check_path" && break
    return 0
  done
  echo "Installing npm packages." >&2
  subcmd_npm install "$@"
  touch "$last_check_path"
}

run_node_modules_bin() { # Run the bin file in the node_modules.
  local pkg="$1"
  shift
  local bin_path="$1"
  shift
  subcmd_npm__install
  local p="$TASKS_DIR"/node_modules/"$pkg"/"$bin_path"
  if test -f "$p" && head -1 "$p" | grep -q '^#!.*node'
  then
    subcmd_node "$p" "$@"
    return $?
  fi
  if is_windows
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

subcmd_npm__dev__install() { # Install the npm packages for development.
  subcmd_npm install --save --include-dev "$@"
}

subcmd_npm__ensure() { # Ensure the npm packages are installed.
  local package
  for package in "$@"
  do
    if ! subcmd_node -e "require.resolve('${package}')" >/dev/null 2>&1
    then
      subcmd_npm install --save --include-dev "${package}"
    fi
  done
}
