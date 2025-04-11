#!/bin/sh
set -o nounset -o errexit

test "${guard_dce0096+set}" = set && return 0; guard_dce0096=x

. ./task.sh

# set_sync_ignored .venv

# https://github.com/astral-sh/uv/releases/download/0.4.21/uv-i686-pc-windows-msvc.zip
# https://github.com/astral-sh/uv/releases/download/0.4.21/uv-x86_64-pc-windows-msvc.zip


uv_dir_path() (
  cmd_base=uv
  ver=0.4.21

  bin_dir_path="$HOME"/.bin
  uv_dir_path="$bin_dir_path/${cmd_base}@${ver}"
  mkdir -p "$uv_dir_path"
  uv_cmd_path="$uv_dir_path/$cmd_base$(exe_ext)"
  if ! test -x "$uv_cmd_path"
  then
    vendor=unknown
    runtime=
    arc_ext=".tar.gz"
    case "$(uname -s)" in
      Linux)
        runtime=-gnu
        rust_os="linux"
        ;;
      Darwin)
        vendor=apple
        rust_os="darwin"
        ;;
      Windows_NT)
        vendor=pc
        rust_os="windows"
        runtime=-msvc
        arc_ext=".zip"
        ;;
      *) echo "Unsupported platform: $(uname -s)" >&2; exit 1 ;;
    esac
    case "$(uname -m)" in
      i386 | i486 | i586 | i686) rust_arch="i686" ;;
      x86_64) rust_arch="x86_64" ;;
      arm64) rust_arch="aarch64" ;;
      *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
    esac
    url="https://github.com/astral-sh/uv/releases/download/$ver/uv-${rust_arch}-${vendor}-${rust_os}${runtime}${arc_ext}"
    temp_file_path=$(get_temp_dir_path)/tmp"$arc_ext"
    curl"$(exe_ext)" --fail --location "$url" -o "$temp_file_path"
    mkdir -p "$uv_dir_path"
    cd "$uv_dir_path"
    case "$arc_ext" in
      .tar.gz)
        tar"$(exe_ext)" -xf "$temp_file_path"
        mv uv-*/* .
        rmdir uv-*/
        ;;
      .zip)
        unzip -o "$temp_file_path"
        ;;
    esac
    chmod +x "$uv_dir_path"/*
  fi
  echo "$uv_dir_path"
)

set_uv_env() {
  test "${guard_10c8d60+set}" = set && return 0; guard_10c8d60=x
  PATH="$(uv_dir_path):$PATH"
}

uv() {
  set_uv_env
  invoke uv "$@"
}

subcmd_uv() { # Run uv(1)
  uv "$@"
}

uvx() {
  set_uv_env
  invoke uvx "$@"
}

subcmd_uvx() { # Run uvx(1)
  uvx "$@"
}

python3() {
  uv run python3 "$@"
}

subcmd_python3() { # Run python3 in a UV environment
  python3 "$@"
}
