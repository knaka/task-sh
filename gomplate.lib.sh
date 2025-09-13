# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_75a3d73-false}" && return 0; sourced_75a3d73=true

# Releases · hairyhenderson/gomplate https://github.com/hairyhenderson/gomplate

. ./task.sh

# Releases · hairyhenderson/gomplate https://github.com/hairyhenderson/gomplate/releases
gomplate_version_7424251="v4.3.3"

set_gomplate_version() {
  gomplate_version_7424251="$1"
}

gomplate() {
  # shellcheck disable=SC2016
  run_fetched_cmd \
    --name="gomplate" \
    --ver="$gomplate_version_7424251" \
    --os-map="$goos_map" \
    --arch-map="$goarch_map" \
    --url-template='https://github.com/hairyhenderson/gomplate/releases/download/${ver}/gomplate_${os}-${arch}${exe_ext}' \
    -- \
    "$@"
}

# Run gomplate(1).
subcmd_gomplate() {
  gomplate "$@"
}
