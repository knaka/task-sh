#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_995e5cd-false}" && return 0; sourced_995e5cd=true

# set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
# cd "$1"; shift 2

brew_apply() {
  # 宣言的に記述された ~/.Brewfile に基づいて、冪等にパッケージをインストール・アンインストールする
  brew bundle --global --cleanup install "$@"
  # brew bundle --global install "$@"
}

case "${0##*/}" in
  (brew-apply.sh|brew-apply)
    set -o nounset -o errexit
    brew_apply "$@"
    ;;
esac
