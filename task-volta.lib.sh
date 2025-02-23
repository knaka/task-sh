#!/bin/sh
test "${guard_1c3e8cf+set}" = set && return 0; guard_1c3e8cf=x
set -o nounset -o errexit

. ./task.sh

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
    temp_dir_path="$TEMP_DIR"/volta
    mkdir -p "$temp_dir_path"
    fetch "$url" >"$temp_dir_path"/tmp"$arc_ext"
    (cd "$volta_dir_path"; tar"$(exe_ext)" -xf "$temp_dir_path"/tmp"$arc_ext")
    chmod +x "$volta_dir_path"/*
    # Volta binary is not statically linked.
    if is_alpine
    then
      apk add libstdc++ 1>&2
    fi
  fi
  echo "$volta_dir_path"
)

set_volta_env() {
  first_call 80498e1 || return 0
  PATH="$(volta_dir_path):$PATH"
  export PATH
}

set_node_env() {
  first_call ae97cdf || return 0
  set_volta_env
  PATH="$(dirname "$(subcmd_volta which node)"):$PATH"
  export PATH
}

subcmd_volta() { # Run Volta.
  set_volta_env
  invoke volta "$@"
}
