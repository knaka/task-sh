#!/bin/sh
test "${guard_1c3e8cf+set}" = set && return 0; guard_1c3e8cf=x
set -o nounset -o errexit

. ./task.sh

# Releases · volta-cli/volta https://github.com/volta-cli/volta/releases
volta_version_c919009=2.0.2

set_volta_version() {
  volta_version_c919009="$1"
}

volta_dir_path() {
  local saved_ifs="$IFS"; IFS=","
  # shellcheck disable=SC2016
  run_fetched_cmd \
    --name="volta" \
    --ver="$volta_version_c919009" \
    --os-map="Linux,linux,Darwin,macos,Windows,windows," \
    --arch-map="x86_64,,aarch64,-arm," \
    --ext-map="Linux,.tar.gz,Darwin,.tar.gz,Windows,.zip," \
    --url-template='https://github.com/volta-cli/volta/releases/download/v${ver}/volta-${ver}-${os}${arch}${ext}' \
    --print-dir
  IFS="$saved_ifs"
}

set_volta_env() {
  first_call 80498e1 || return 0
  PATH="$(volta_dir_path):$PATH"
  export PATH
}

volta() {
  set_volta_env
  invoke volta "$@"
}

subcmd_volta() { # Run Volta.
  volta "$@"
}

set_node_env() {
  first_call ae97cdf || return 0
  set_volta_env
  PATH="$(dirname "$(volta which node)"):$PATH"
  export PATH
}
