#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_b2b6357-false}" && return 0; sourced_b2b6357=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
cd "$1"; shift 2

# Remove untracked files in the git work of the current directory.
git_rm_untracked() {
  git clean -d --force
}

case "${0##*/}" in
  (git-rm-untracked.sh|git-rm-untracked)
    set -o nounset -o errexit
    git_rm_untracked "$@"
    ;;
esac
