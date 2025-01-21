#!/bin/sh
# shellcheck disable=SC3043
set -o nounset -o errexit

test "${guard_ca67a57+set}" = set && return 0; guard_ca67a57=-

. ./task.sh

set_sync_ignored node_modules

set_sync_ignored .env*.local || :

volta_dir_path() (
  # Releases · volta-cli/volta https://github.com/volta-cli/volta/releases
  cmd_base=volta
  ver=2.0.1

  bin_dir_path="$HOME"/.bin
  volta_dir_path="$bin_dir_path/${cmd_base}@${ver}"
  mkdir -p "$volta_dir_path"
  volta_cmd_path="$volta_dir_path/$cmd_base$(exe_ext)"
  if ! test -x "$volta_cmd_path"
  then
    arc_ext=".tar.gz"
    case "$(uname -s)" in
      Linux)
        case "$(uname -m)" in
          x86_64) os_arch="linux" ;;
          arm64) os_arch="linux-arm" ;;
          *)
            echo "Unspoorted architecture: $(uname -m)" >&2
            exit 1;;
        esac
        ;;
      Darwin)
        # Mach-O universal binarries.
        os_arch="macos"
        ;;
      Windows_NT)
        arc_ext=".zip"
        case "$(uname -m)" in
          x86_64) os_arch="windows" ;;
          arm64) os_arch="windows-arm64" ;;
          *) exit 1;;
        esac
        ;;
      *)
        echo "Unsupported OS: $(uname -s)" >&2
        exit 1
        ;;
    esac
    url=https://github.com/volta-cli/volta/releases/download/v${ver}/volta-${ver}-${os_arch}${arc_ext}
    temp_dir_path="$(mktemp -d)"
    curl"$(exe_ext)" --fail --location "$url" -o "$temp_dir_path"/tmp"$arc_ext"
    (cd "$volta_dir_path"; tar"$(exe_ext)" -xf "$temp_dir_path"/tmp"$arc_ext")
    chmod +x "$volta_dir_path"/*
    rm -fr "$temp_dir_path"
  fi
  echo "$volta_dir_path"
)

set_volta_env() {
  if test "${guard_fc3b530+set}" = set
  then
    return 0
  fi
  guard_fc3b530=x
  PATH="$(volta_dir_path):$PATH"
  export PATH
}

set_node_env() {
  first_call a7e6214 || return 0
  set_volta_env
  PATH="$(dirname "$(subcmd_volta which node)"):$PATH"
  export PATH
}

subcmd_volta() { # Run volta.
  set_volta_env
  volta"$(exe_ext)" "$@"
}

subcmd_npm() { # Run npm.
  set_node_env
  cross_run npm "$@"
}

subcmd_npx() { # Run npx.
  set_node_env
  cross_run npx "$@"
} 

subcmd_node() { # Run node.
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

node_moduels_run_bin() { # Run the bin file in the node_modules.
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