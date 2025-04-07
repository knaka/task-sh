# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_f2524bb-false}" && return 0; sourced_f2524bb=true

# jqlang/jq: Command-line JSON processor https://github.com/jqlang/jq

. ./task.sh

# Releases · jqlang/jq https://github.com/jqlang/jq/releases
jq_version_9256b0f="1.7.1"

set_jq_version() {
  jq_version_9256b0f="$1"
}

jq() {
  local app_dir_path="$(cache_dir_path)"/jq
  mkdir -p "$app_dir_path"
  local cmd_path="$app_dir_path"/jq@"$jq_version_9256b0f""$exe_ext"
  if ! command -v "$cmd_path" >/dev/null 2>&1
  then
    local os_arch="$(uname -s -m)"
    local os
    case "${os_arch% *}" in
      (Linux) os="linux" ;;
      (Darwin) os="osx" ;;
      (Windows) os="windows" ;;
      (*) return 1 ;;
    esac
    local arch
    case "${os_arch#* }" in
      (x86_64) arch="amd64" ;;
      (aarch64) arch="arm64" ;;
      (*) return 1 ;;
    esac
    local url="https://github.com/jqlang/jq/releases/download/jq-$jq_version_9256b0f/jq-$os-$arch$exe_ext"
    echo "Downloading jq from $url" >&2
    curl --fail --location "$url" --output "$cmd_path"
    chmod +x "$cmd_path"
  fi
  "$cmd_path" "$@"
}

subcmd_jq() { # Run jq(1).
  jq "$@"
}
