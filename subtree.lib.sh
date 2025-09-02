# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_5aae4b0-false}" && return 0; sourced_5aae4b0=true

. ./task.sh
. ./yq.lib.sh

subcmd_subtree__add() { # Add git-subtree to this project.
  if test "$#" -lt 2
  then
    cat <<EOF >&2
Usage: subtree:add <target_dir> <repository> [<branch>]

Adds a subtree from the specified branch of <repository> to the current repository. If branch is not specified, uses "main" or "master" according to the repository.
EOF
    return 1
  fi
  local toplevel="$(git rev-parse --show-toplevel)"
  if test "$(realpath "$toplevel")" != "$(realpath "$PWD")"
  then
    echo "Execute this command at the top-level directory of the git worktree." >&2
    return 1
  fi
  local target_dir="$1"
  shift
  if test -e "$target_dir"
  then
    echo "\"$target_dir\" already exists. Aborting." >&2
    return 1
  fi
  local repository="$1"
  shift
  local branch
  if test "$#" -gt 0
  then
    branch="$1"
    shift
  else
    echo "Detecting the main branch for \"$repository\" ..." >&2
    local refs="$(git ls-remote "$repository")"
    if echo "$refs" | grep -q 'refs/heads/main$'
    then
      branch=main
    elif echo "$refs" | grep -q 'refs/heads/master$'
    then
      branch=master
    else
      echo "No \"main\" or \"master\" branch found in $repository" >&2
      exit 1
    fi
  fi
  git subtree add --prefix "$target_dir" "$repository" "$branch"
  touch .subtree.yaml
  yq --inplace ".\"$target_dir\".repository = \"$repository\" | .\"$target_dir\".branch = \"$branch\"" .subtree.yaml
}

subcmd_subtree__remove() { # Remove git-subtree from this project.
  local target_dir="$1"
  git rm -rf "$target_dir"
  touch .subtree.yaml
  yq --inplace "del(.\"$target_dir\")" .subtree.yaml
}

subtree() {
  local git_subcmd="$1"
  local target_dir="$2"
  local repository="$(yq ".\"$target_dir\".repository" .subtree.yaml)"
  local branch="$(yq ".\"$target_dir\".branch" .subtree.yaml)"
  # echo debug - cmd: "$git_subcmd", target_dir: "$target_dir", repository: "$repository", branch: "$branch" >&2
  git subtree "$git_subcmd" --prefix "$target_dir" "$repository" "$branch"
}

subcmd_subtree__push() {
  subtree push "$@"
}

subcmd_subtree__pull() {
  subtree pull "$@"
}
