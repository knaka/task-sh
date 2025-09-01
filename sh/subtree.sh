#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_7c91e54-false}" && return 0; sourced_7c91e54=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./task.sh
cd "$1"; shift 2

set -o nounset -o errexit

show_help() {
  echo "Usage: $0 add <repository> [<target_dir>]" >&2
  echo "   or: $0 <push|pull|log>" >&2
}

base="$(basename "$0")"
case "$base" in
  subtree-add) cmd=add ;;
  subtree-push) cmd=push ;;
  subtree-pull) cmd=pull ;;
  *)
    if test "${1+SET}" != SET
    then
      echo "Command not specified." >&2
      show_help
      exit 1
    fi
    cmd="$1"
    shift
    ;;
esac

case "$cmd" in
  # add <repository> [<target_dir>]
  #   Adds a subtree from the “main” branch of <repository> to the current repository.
  #   If <target_dir> is not specified, the target directory is the basename of <repository>.
  #   The repository URL and the branch name are stored in .repository-<repo_base> and .branch-<repo_base> files in the parent directory of the target directory to be used by push and pull commands.
  add)
    if test "${1+SET}" != SET
    then
      echo "Repository not specified." >&2
      show_help
    fi
    repository="$1"
    shift
    target_dir=
    if test "${1+SET}" = SET
    then
      target_dir="$1"
      shift
    fi
    echo "Detecting \"main\" branch for \"$repository\" ..." >&2
    refs="$(git ls-remote "$repository")"
    branch=
    if echo "$refs" | grep -q '/main$'
    then
      branch=main
    elif echo "$refs" | grep -q '/master$'
    then
      branch=master
    else
      echo "No \"main\" or \"master\" branch found in $repository"
      exit 1
    fi
    echo "\"main\" branch is \"$branch\"" >&2
    toplevel="$(git rev-parse --show-toplevel)"
    repo_base="$(basename "$repository" | perl -pe 's/\.git$//')"
    if test -n "$target_dir"
    then
      prefix_abs="$(realpath "$target_dir")"
      echo 12ee2b2: "$target_dir", "$prefix_abs"
    else
      prefix_abs="$PWD/$repo_base"
    fi
    dir_base="$(basename "$prefix_abs")"
    cd "$toplevel"
    prefix="$(abs2rel "$prefix_abs")"
    git subtree add --prefix "$prefix" "$repository" "$branch"
    path="$prefix/../.${dir_base}.subtree"
    echo "repository=\"$repository\"" > "$path"
    echo "branch=\"$branch\"" >> "$path"
    ;;
  push|pull)
    if test -e .git
    then
      echo "This directory is not a subtree."
      exit 1
    fi
    dir_base="$(basename "$PWD")"
    repository=
    branch=
    # shellcheck disable=SC1090
    . "../.${dir_base}.subtree"
    toplevel="$(git rev-parse --show-toplevel)"
    prefix=${PWD##"$toplevel"/}
    cd "$toplevel"
    case "$cmd" in
      push) git subtree push --prefix "$prefix" "$repository" "$branch" ;;
      pull) git subtree pull --prefix "$prefix" "$repository" --squash "$branch" ;;
      *)
        show_help
        exit 1
        ;;
    esac
    ;;
  log)
    git log --grep="git-subtree-dir:"
    ;;
  help)
    show_help
    ;;
  *)
    show_help
    exit 1
    ;;
esac

