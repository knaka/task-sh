#!/bin/sh
test "${guard_1c3e8cf+set}" = set && return 0; guard_1c3e8cf=x
set -o nounset -o errexit

# Volta - The Hassle-Free JavaScript Tool Manager https://volta.sh/

. ./task.sh

# Releases · volta-cli/volta https://github.com/volta-cli/volta/releases
volta_version_c919009=2.0.2

set_volta_version() {
  volta_version_c919009="$1"
}

volta() {
  # shellcheck disable=SC2016
  run_fetched_cmd \
    --name="volta" \
    --ver="$volta_version_c919009" \
    --cmd="volta" \
    --ifs="," \
    --os-map="Linux,linux,Darwin,macos,Windows,windows," \
    --arch-map="x86_64,,aarch64,-arm," \
    --ext-map="Linux,.tar.gz,Darwin,.tar.gz,Windows,.zip," \
    --url-template='https://github.com/volta-cli/volta/releases/download/v${ver}/volta-${ver}-${os}${arch}${ext}' \
    -- \
    "$@"
}

subcmd_volta() { # Run Volta.
  volta "$@"
}
