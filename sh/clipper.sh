#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_c48b48e-false}" && return 0; sourced_c48b48e=true

# Run Clipper, a command-line tool to summarize web pages into Markdown format. // philschmid/clipper.js: HTML to Markdown converter and crawler. https://github.com/philschmid/clipper.js

# @philschmid/clipper - npm https://www.npmjs.com/package/@philschmid/clipper
name_ff71911="@philschmid/clipper"
version_2b8a94e=0.2.0

set_clipper_version() {
  version_2b8a94e="$1"
}

# Releases · nodejs/node https://github.com/nodejs/node/releases
node_version_c4da3a4=24

set_clipper_node_version() {
  node_version_c4da3a4="$1"
}

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./task-volta.lib.sh
cd "$1"; shift 2

clipper() {
  volta run --node="$node_version_c4da3a4" npx --yes --prefer-offline "$name_ff71911@$version_2b8a94e" "$@"
}

case "${0##*/}" in
  (clipper.sh|clipper)
    set -o nounset -o errexit
    clipper "$@"
    ;;
esac
