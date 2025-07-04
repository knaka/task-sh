# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_0fe9d5f-false}" && return 0; sourced_0fe9d5f=true

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
    curl --fail --location --output "$cmd_path" "https://github.com/mikefarah/yq/releases/download/${yq_version_c887ee2}/yq_$(go_os)_$(go_arch)$exe_ext"
    chmod +x "$cmd_path"
  fi
  invoke "$cmd_path" "$@"
}

subcmd_yq() { # Run yq(1).
  yq "$@"
}
