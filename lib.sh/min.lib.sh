# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_679bf07-false}" && return 0; sourced_679bf07=true

: "${psv_dirs_6b8d832="$PWD"|}"

# Call before relative path sourcing.
before_source() {
  cd "${psv_dirs_6b8d832%%|*}" || exit 1
  psv_dirs_6b8d832="$PWD/$1|$psv_dirs_6b8d832"
}

# Call after relative path sourcing.
after_source() {
  psv_dirs_6b8d832="${psv_dirs_6b8d832#*|}"
  cd "${psv_dirs_6b8d832%%|*}" || exit 1
}
