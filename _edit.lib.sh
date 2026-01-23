# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_06877c8-false}" && return 0; sourced_06877c8=true

. ./task.sh

extract_block() {
  local begin_marker="$1"
  local end_marker="$2"
  local file_path="$3"
  sed -n "/${begin_marker}/,/${end_marker}/p" "${file_path}"
}

exclude_block() {
  local begin_marker="$1"
  local end_marker="$2"
  local file_path="$3"
  sed "/${begin_marker}/,/${end_marker}/d" "${file_path}"
}

extract_before() {
  local marker="$1"
  local file_path="$2"
  sed -n "1,/${marker}/p" "${file_path}"
}

extract_after() {
  local marker="$1"
  local file_path="$2"
  sed -n "/${marker}/,\$p" "${file_path}"
}
