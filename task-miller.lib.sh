#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_b2dc4e9-false}" && return 0; sourced_b2dc4e9=true

# johnkerl/miller: Miller is like awk, sed, cut, join, and sort for name-indexed data such as CSV, TSV, and tabular JSON https://github.com/johnkerl/miller

# Releases · johnkerl/miller · GitHub https://github.com/johnkerl/miller/releases
mlr_version_4bb65e2="6.13.0"

set_mlr_version() {
  mlr_version_4bb65e2="$1"
}

. ./task.sh

mlr() {
  # shellcheck disable=SC2016
  fetch_cmd_run \
    --name="miller" \
    --ver="$mlr_version_4bb65e2" \
    --cmd="mlr" \
    --os-map="$goos_map" \
    --arch-map="$goarch_map" \
    --ext-map="$archive_ext_map" \
    --url-template='https://github.com/johnkerl/miller/releases/download/v${ver}/${name}-${ver}-${os}-${arch}${ext}' \
    --rel-dir-template='${name}-${ver}-${os}-${arch}' \
    -- \
    "$@"
}

subcmd_mlr() { # Run Miller command
  mlr "$@"
}
