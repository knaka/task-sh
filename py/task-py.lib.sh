#!/bin/sh
set -o nounset -o errexit

test "${guard_6d6de14+set}" = set && return 0; guard_6d6de14=-

. task.sh

subcmd_rye() ( # Execute rye.
  # Releases · astral-sh/rye https://github.com/astral-sh/rye/releases
  cmd_base="rye"
  ver="0.39.0"

  if ! realpath "$PWD" | grep -q -e "^$script_dir_path"
  then
    echo "Please run this subcommand in the same directory as the script." >&2
    exit 1
  fi

  arc_ext=".gz"
  case "$(uname -s)" in
    Linux) rust_os="linux" ;;
    Darwin) rust_os="macos" ;;
    Windows_NT)
      arc_ext=".exe"
      rust_os="windows"
      ;;
    *) echo "Unsupported platform: $(uname -s)" >&2; exit 1 ;;
  esac
  bin_dir_path="$HOME/.bin"
  cmd_path="${bin_dir_path}/${cmd_base}@${ver}$(exe_ext)"
  if ! test -x "$cmd_path"
  then
    mkdir -p "$bin_dir_path"
    case "$(uname -m)" in
      i386 | i486 | i586 | i686) rust_arch="x86" ;;
      x86_64) rust_arch="x86_64" ;;
      arm64) rust_arch="aarch64" ;;
      *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
    esac
    if test "$arc_ext" = ".exe"
    then
      curl --location -o "$cmd_path" \
        "https://github.com/astral-sh/rye/releases/download/${ver}/rye-${rust_arch}-${rust_os}${arc_ext}"
    else
      curl --location -o - "https://github.com/astral-sh/rye/releases/download/${ver}/rye-$rust_arch-$rust_os$arc_ext" |
        gunzip --stdout - > "$cmd_path"
      chmod +x "$cmd_path"
    fi
  fi
  "$cmd_path" "$@"
)
