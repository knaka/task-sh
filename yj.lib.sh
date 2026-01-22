# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_9da9669-false}" && return 0; sourced_9da9669=true

. ./task.sh

# Releases · sclevine/yj https://github.com/sclevine/yj/releases
yj_version_999677b="5.1.0"

# shellcheck disable=SC2016
yj() {
  local template='https://github.com/sclevine/yj/releases/download/v${ver}/yj-${os}-${arch}'
  if is_windows
  then
    template='https://github.com/sclevine/yj/releases/download/v${ver}/yj.exe'
  fi
  run_fetched_cmd \
    --name="yj" \
    --ver="$yj_version_999677b" \
    --os-map="Darwin macos $goos_map" \
    --arch-map="$goarch_map" \
    --url-template="$template" \
    -- \
    "$@"
}

# yj(1) format converter
subcmd_yj() {
  yj "$@"
}
