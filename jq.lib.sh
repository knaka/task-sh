# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_f2524bb-false}" && return 0; sourced_f2524bb=true

# jqlang/jq: Command-line JSON processor https://github.com/jqlang/jq

jq_prefer_pkg_ec51165=false

# [boolean] Make use of jq(1) which is installed by platform-specific package manager rather than fetched binary.
set_jq_prefer_pkg() {
  jq_prefer_pkg_ec51165="$1"
}

# Releases · jqlang/jq · GitHub https://github.com/jqlang/jq/releases
jq_version_6d4ce66=1.8.1

set_jq_version() {
  jq_version_6d4ce66="$1"
}

. ./task.sh

require_pkg_cmd \
  --brew-id=jq \
  --winget-id=jqlang.jq \
  /usr/local/bin/jq \
  "$LOCALAPPDATA"/Microsoft/WinGet/Links/jq.exe \
  jq

jq() {
  if "$jq_prefer_pkg_ec51165"
  then
    run_pkg_cmd jq "$@"
    return 0
  fi
  # shellcheck disable=SC2016
  run_fetched_cmd \
    --name="jq" \
    --ver="$jq_version_6d4ce66" \
    --os-map="Darwin macos $goos_map" \
    --arch-map="$goarch_map" \
    --url-template='https://github.com/jqlang/jq/releases/download/jq-$ver/jq-$os-$arch$exe_ext' \
    -- \
    "$@"
}

# Run jq(1).
subcmd_jq() {
  jq "$@"
}
