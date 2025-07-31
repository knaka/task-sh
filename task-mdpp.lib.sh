# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_02dddda-false}" && return 0; sourced_02dddda=true

. ./task.sh

mdpp_version_91a5418=v0.9.5

set_mdpp_version() {
  mdpp_version_91a5418="$1"
}

mdpp() {
  # shellcheck disable=SC2016
  run_fetched_cmd \
    --name="mdpp" \
    --ver="$mdpp_version_91a5418" \
    --os-map="$goos_camel_map" \
    --arch-map="x86_64 x86_64 aarch64 arm64 " \
    --ext-map="$archive_ext_map" \
    --url-template='https://github.com/knaka/mdpp/releases/download/${ver}/mdpp_${os}_${arch}${ext}' \
    -- \
    "$@"
}

subcmd_mdpp() { # Run mdpp(1)
  mdpp "$@"
}
