# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_b6e5666-false}" && return 0; sourced_b6e5666=true

# JFryy/qq: jq, but with many interoperable configuration format transcodings and interactive querying. https://github.com/JFryy/qq

. ./task.sh

# Releases · JFryy/qq https://github.com/JFryy/qq/releases
qq_version_0d37f4b="v0.3.1"

set_qq_version() {
  qq_version_0d37f4b="$1"
}

qq() {
  # shellcheck disable=SC2016
  run_fetched_cmd \
    --name="qq" \
    --ver="$qq_version_0d37f4b" \
    --os-map="$goos_map" \
    --arch-map="$goarch_map" \
    --ext-map="$archive_ext_map" \
    --url-template='https://github.com/JFryy/qq/releases/download/${ver}/qq-${ver}-${os}-${arch}${ext}' \
    --rel-dir-template="." \
    -- \
    "$@"
}

# Run qq(1).
subcmd_qq() {
  qq "$@"
}
