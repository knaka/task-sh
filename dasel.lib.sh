# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_431249b-false}" && return 0; sourced_431249b=true

. ./task.sh

# TomWright/dasel: Select, put and delete data from JSON, TOML, YAML, XML, INI, HCL and CSV files with a single tool. Also available as a go mod. https://github.com/TomWright/dasel

# 2026-01-22T10:11:14+0900: Dasel v3 was released in December 2025. The version drastically changed the language specifications and command system, and they do not seem mature yet. Keep using version "2" for now.

# Releases · TomWright/dasel https://github.com/TomWright/dasel/releases
dasel_version_12A6124="2.8.1"

dasel() {
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
