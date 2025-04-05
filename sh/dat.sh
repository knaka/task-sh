#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_1ed55fa-false}" && return 0; sourced_1ed55fa=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
cd "$1"; shift 2

dat_path="$HOME"/dat

dat() {
  local doc="$1"
  shift
  local i
  for i in "$dat_path"/"$doc".json "$dat_path"/"$doc"-*.json
  do
    if test -r "$i"
    then
      cat "$i"
    fi
  done | jq "$@"
  for i in "$dat_path"/"$doc".yml "$dat_path"/"$doc".yaml "$dat_path"/"$doc"-*.yml "$dat_path"/"$doc"-*.yaml
  do
    if test -r "$i"
    then
      cat "$i"
    fi
  done | yq -o json "$@"
}

case "${0##*/}" in
  (dat.sh|dat)
    set -o nounset -o errexit
    dat "$@"
    ;;
esac
