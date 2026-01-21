# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_7e3d8bc-false}" && return 0; sourced_7e3d8bc=true

. ./task.sh

# twpayne/chezmoi: Manage your dotfiles across multiple diverse machines, securely. https://github.com/twpayne/chezmoi

# Releases · twpayne/chezmoi https://github.com/twpayne/chezmoi/releases
chezmoi_version_BEF5598="2.69.3"

chezmoi() {
  # shellcheck disable=SC2016
  run_fetched_cmd \
    --name="chezmoi" \
    --ver="$chezmoi_version_BEF5598" \
    --os-map="$goos_map" \
    --arch-map="$goarch_map" \
    --ext-map="$archive_ext_map" \
    --url-template='https://github.com/twpayne/chezmoi/releases/download/v${ver}/chezmoi_${ver}_${os}_${arch}${ext}' \
    -- \
    "$@"
}
