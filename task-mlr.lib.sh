#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_b2dc4e9-false}" && return 0; sourced_b2dc4e9=true

# Releases · johnkerl/miller · GitHub https://github.com/johnkerl/miller/releases
mlr_version_4bb65e2="6.13.0"

set_mlr_version() {
  mlr_version_4bb65e2="$1"
}

. ./task.sh

mlr() {
  local app_dir_path="$(cache_dir_path)"/mlr
  mkdir -p "$app_dir_path"
  local cmd_path="$app_dir_path"/mlr@"$mlr_version_4bb65e2""$exe_ext"
  if ! command -v "$cmd_path" >/dev/null 2>&1
  then
    local os_arch="$(uname -s -m)"
    local os
    local arch_ext=".tar.gz"
    case "${os_arch% *}" in
      (Linux) os="linux" ;;
      (Darwin) os="darwin" ;;
      (Windows)
        os="windows"
        arch_ext=".zip"
        ;;
      (*) return 1 ;;
    esac
    local arch
    case "${os_arch#* }" in
      (x86_64) arch="amd64" ;;
      (aarch64) arch="arm64" ;;
      (*) return 1 ;;
    esac
    local url="https://github.com/johnkerl/miller/releases/download/v${mlr_version_4bb65e2}/miller-${mlr_version_4bb65e2}-${os}-${arch}${arch_ext}"
    echo "Downloading Miller from $url" >&2
    local temp_dir_path="$TEMP_DIR"
    curl --fail --location "$url" --output "$temp_dir_path"/temp"$arch_ext"
    push_dir "$temp_dir_path"
    if test "$arch_ext" = ".zip"
    then
      unzip temp"$arch_ext"
    else
      tar -xf temp"$arch_ext"
    fi
    mv "miller-${mlr_version_4bb65e2}-${os}-${arch}"/"mlr${exe_ext}" "$cmd_path"
    chmod +x "$cmd_path"
    pop_dir
  fi
  "$cmd_path" "$@"
}

subcmd_mlr() { # Run Miller command
  mlr "$@"
}
