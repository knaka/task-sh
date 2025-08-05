#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_185ce30-false}" && return 0; sourced_185ce30=true

# Read URLs from standard input, summarize the corresponding web page content with Readability, and output as a single concatenated Markdown document.

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./clipper.sh
cd "$1"; shift 2

urls2md() {
  local temp_file="$TEMP_DIR"/temp.md
  while read -r url
  do
    echo "$url" >&2
    clipper clip -u "$url" -o "$temp_file"
    sed -E -e "s@^# (.*)\$@# [\1]($url)@" "$temp_file"
    echo
    echo
  done
}

case "${0##*/}" in
  (urls2md.sh|urls2md)
    set -o nounset -o errexit
    urls2md "$@"
    ;;
esac
