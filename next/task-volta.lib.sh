#!/bin/sh
set -o nounset -o errexit

test "${guard_ca67a57+set}" = set && return 0; guard_ca67a57=-

. task.sh

mkdir -p node_modules
set_sync_ignored node_modules

set_sync_ignored .env*.local || :

volta_cmd_path() (
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
  echo "$volta_cmd_path"
)

set_volta_env() {
  if test "${guard_fc3b530+set}" = set
  then
    return 0
  fi
  guard_fc3b530=x
  PATH="$(dirname "$(volta_cmd_path)"):$PATH"
  export PATH
}

set_node_env() {
  if test "${guard_54448e7+set}" = set
  then
    return 0
  fi
  guard_54448e7=x
  set_volta_env
  PATH="$(dirname "$(subcmd_volta which node)"):$PATH"
  export PATH
}

subcmd_volta() {
  set_volta_env
  "$(volta_cmd_path)" "$@"
}

# npm_cmd_path() {
#   subcmd_volta which npm
# }

subcmd_npm() { # Run npm.
  # This fails on Windows.
  # "$(npm_cmd_path)" "$@"
  subcmd_volta run npm "$@"
}

npx_cmd_path() {
  subcmd_volta which npx
}

subcmd_npx() { # Run npx.
  # "$(npx_cmd_path)" "$@"
  subcmd_volta run npx "$@"
} 

# node_cmd_path() {
#   subcmd_volta which node
# }

subcmd_node() {
  "$(node_cmd_path)" "$@"
}
