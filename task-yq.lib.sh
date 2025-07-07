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
  # shellcheck disable=SC2016
  fetch_cmd_run \
    --name="yq" \
    --ver="$yq_version_c887ee2" \
    --os-map="$goos_map" \
    --arch-map="$goarch_map" \
    --url-template='https://github.com/mikefarah/yq/releases/download/${ver}/yq_${os}_${arch}${exe_ext}' \
    -- \
    "$@"
}

subcmd_yq() { # Run yq(1).ß
  yq "$@"
}
