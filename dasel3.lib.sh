# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_d4e6289-false}" && return 0; sourced_d4e6289=true

. ./task.sh

# TomWright/dasel: Select, put and delete data from JSON, TOML, YAML, XML, INI, HCL and CSV files with a single tool. Also available as a go mod. https://github.com/TomWright/dasel

# Releases · TomWright/dasel https://github.com/TomWright/dasel/releases
dasel_version_12A6124="3.2.1"

dasel3() {
  # shellcheck disable=SC2016
  run_fetched_cmd \
    --name="dasel" \
    --ver="$dasel_version_12A6124" \
    --os-map="$goos_map" \
    --arch-map="$goarch_map" \
    --url-template='https://github.com/TomWright/dasel/releases/download/v${ver}/dasel_${os}_${arch}' \
    -- \
    "$@"
}

# dasel(1) version 3
subcmd_dasel3() {
  dasel3 "$@"
}
