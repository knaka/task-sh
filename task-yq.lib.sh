# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_0fe9d5f-false}" && return 0; sourced_0fe9d5f=true

# mikefarah/yq: yq is a portable command-line YAML, JSON, XML, CSV, TOML and properties processor https://github.com/mikefarah/yq

. ./task.sh

# Releases · mikefarah/yq https://github.com/mikefarah/yq/releases
yq_version_c887ee2="v4.45.1"

set_yq_version() {
  yq_version_c887ee2="$1"
}

yq() {
  local app_dir_path="$(cache_dir_path)"/yq
  mkdir -p "$app_dir_path"
  local cmd_path="$app_dir_path"/yq@"$yq_version_c887ee2""$exe_ext"
  if ! command -v "$cmd_path" >/dev/null 2>&1
  then
    local os_arch="$(uname -s -m)"
    local os
    case "${os_arch% *}" in
      (Linux) os="linux" ;;
      (Darwin) os="darwin" ;;
      (Windows) os="windows" ;;
      (*) return 1 ;;
    esac
    local arch
    case "${os_arch#* }" in
      (x86_64) arch="amd64" ;;
      (aarch64) arch="arm64" ;;
      (*) return 1 ;;
    esac
    local url="https://github.com/mikefarah/yq/releases/download/${yq_version_c887ee2}/yq_${os}_${arch}${exe_ext}"
    echo "Downloading yq from $url" >&2
    curl --fail --location "$url" --output "$cmd_path"
    chmod +x "$cmd_path"
  fi
  "$cmd_path" "$@"
}

subcmd_yq() { # Run yq(1).
  yq "$@"
}
