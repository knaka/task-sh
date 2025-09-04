# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_5aae4b0-false}" && return 0; sourced_5aae4b0=true

. ./task.sh
. ./yq.lib.sh

before_each_906801f() {
  local git_top="$(git rev-parse --show-toplevel)"
  test "$(realpath "$git_top")" = "$(realpath "$PWD")" && return 0
  finalize
  cd "$git_top"
  # shellcheck disable=SC2209
  INVOCATION_MODE=exec invoke ./task "$TASK_NAME" "$@"
  # Not reached
  return 1
}

# Add git-subtree to this project.
subcmd_subtree__add() {
  before_each_906801f "$@"
  local toplevel="$(git rev-parse --show-toplevel)"
  if test "$(realpath "$toplevel")" != "$(realpath "$PWD")"
  then
    echo "Execute this command from the top-level directory of the git worktree." >&2
    return 1
  fi
  if test "$#" -eq 1
  then
    local name="$1"
    local info=
    info="$(subtree_info "$name")"
    local repository="$(echo "$info" | yq ".repository")"
    local branch="$(echo "$info" | yq ".branch")"
    local prefix="$(echo "$info" | yq ".prefix")"
    git subtree add --prefix "$prefix" "$repository" "$branch"
  elif test "$#" -ge 2
  then
    local prefix="$1"
    if test -e "$prefix"
    then
      echo "\"$prefix\" already exists. Aborting." >&2
      return 1
    fi
    local repository="$2"
    local branch
    if test "$#" -gt 2
    then
      branch="$3"
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
        echo "No \"main\" or \"master\" branch found in \"$repository\"" >&2
        exit 1
      fi
    fi
    git subtree add --prefix "$prefix" "$repository" "$branch"
    touch .subtree.yaml
    local subtree_alias="$(basename "$prefix")"
    yq --inplace ". += [{\"prefix\": \"$prefix\", \"alias\": \"$subtree_alias\", \"repository\": \"$repository\", \"branch\": \"$branch\"}]" .subtree.yaml
  else
    cat <<EOF >&2
Usage: subtree:add <target_dir> <repository> [<branch>]
   or: subtree:add <prefix|alias>

Adds a subtree from the specified branch of <repository> to the current repository and records the repository and branch to .subtree.yaml. If no branch is specified, automatically detects and uses "main" or "master" from the repository. If only the prefix|alias is specified, repository and branch are picked from the configuration in .subtree.yaml.
EOF
    return 0
  fi
}

# Remove git-subtree from this project.
subcmd_subtree__remove() {
  before_each_906801f "$@"
  local target_dir="$1"
  git rm -rf "$target_dir"
  touch .subtree.yaml
  yq --inplace "del(.\"$target_dir\")" .subtree.yaml
}

subtree() {
  local git_subcmd="$1"
  local name="$2"
  local info=
  info="$(subtree_info "$name")"
  local target_dir="$(echo "$info" | yq ".prefix")"
  local repository="$(echo "$info" | yq ".repository")"
  local branch="$(echo "$info" | yq ".branch")"
  git subtree "$git_subcmd" --prefix "$target_dir" "$repository" "$branch"
}

# Push subtree changes to remote repository.
subcmd_subtree__push() {
  before_each_906801f "$@"
  subtree push "$@"
}

# Pull subtree changes from remote repository.
subcmd_subtree__pull() {
  before_each_906801f "$@"
  subtree pull "$@"
}

subtree_info() {
  before_each_906801f "$@"
  local name="$1"
  local info="$(yq ".[] | select(.prefix == \"$name\" or .alias == \"$name\")" .subtree.yaml)"
  if test -z "$info"
  then
    echo "\"$name\" is not a valid subtree. Aborting." >&2
    return 1
  fi
  echo "$info"
}

# Show information about a subtree.
subcmd_subtree__info() {
  before_each_906801f "$@"
  local name="$1"
  local info=
  info="$(subtree_info "$name")"
  local target_dir="$(echo "$info" | yq ".prefix")"
  git log --grep="git-subtree-dir: $target_dir"
}
