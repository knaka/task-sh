#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_b7ccc35-false}" && return 0; sourced_b7ccc35=true

# Releases · x-motemen/ghq https://github.com/x-motemen/ghq/releases
ghq_version="1.8.0"

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./task.sh
. ./peco.sh
cd "$1"; shift 2

GHQ_ROOT="$HOME"/repos
export GHQ_ROOT

ghq() {
  # shellcheck disable=SC2016
  run_fetched_cmd \
    --name="ghq" \
    --ver="$ghq_version" \
    --os-map="$goos_map" \
    --arch-map="$goarch_map" \
    --ext=".zip" \
    --url-template='https://github.com/x-motemen/ghq/releases/download/v${ver}/ghq_${os}_${arch}${ext}' \
    --rel-dir-template='ghq_${os}_${arch}' \
    -- \
    "$@"
}

if test "${1+set}" = "set"
then
  case "$1" in
    (st|stat)
      set -- ghq root
      ;;
    (*)
      ghq "$@"
      ;;
  esac
fi

# If not subcommand is specified, list repositories.
repo=$(ghq list | peco)
if test -z "${repo}"
then
  exit 1
fi
echo "$(ghq root)"/"${repo}"
