# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_8bca087-false}" && return 0; sourced_8bca087=true

. ./task.sh
. ./jq.lib.sh
. ./yq.lib.sh

# REST API endpoints for Git trees - GitHub Docs https://docs.github.com/en/rest/git/trees
github_tree_api_base="https://api.github.com/repos/knaka/task-sh/git/trees"

# REST API endpoints for repository contents - GitHub Docs https://docs.github.com/en/rest/repos/contents?apiVersion=2022-11-28
# contents_api_base="https://api.github.com/repos/knaka/task-sh/contents/?ref="

github_download_url_base="https://raw.githubusercontent.com/knaka/task-sh"

state_path="$PROJECT_DIR/.task-sh-state.yaml"

# [<name>...] Install task-sh files.
subcmd_task__install() {
  local rc=0
  local resp
  local main_branch=main
  resp="$(curl --silent --fail "${github_tree_api_base}/${main_branch}")"
  local latest_commit="$(echo "$resp" | jq -r .sha)"
  "$VERBOSE" && echo "Latest commit of \"$main_branch\" is \"$latest_commit\"." >&2
  touch "$state_path"
  local file
  local name
  for file in "$@"
  do
    name="${file##*/}"
    "$VERBOSE" && echo "Name: \"$name\"."
    local indent="  "
    local node mode last_sha download_url
    local last_sha=
    last_sha="$(yq eval ".last_sha.\"$name\" // \"\"" "$state_path")"
    "$VERBOSE" && echo "${indent}Last installed SHA:" "$last_sha"
    local local_sha=
    if test -r "$file"
    then
      local_sha="$(git hash-object "$file")"
    fi
    "$VERBOSE" && echo "${indent}Local SHA:" "$local_sha"
    if test -n "$last_sha"
    then
      if test -z "$local_sha"
      then
        :
      elif test "$last_sha" = "$local_sha"
      then
        echo "\"$name\" is up to date, Skipping." >&2
        continue
      else
        echo "\"$name\" is modified locally." >&2
        rc=1
        continue
      fi
    else
      if test "$file" = "$name"
      then
        case "$file" in
          (*/*) ;;
          (*) file="$TASKS_DIR"/"$name"
        esac
      fi
    fi
    node="$(echo "$resp" | jq -c --arg name "$name" '.tree[] | select(.path == $name)')"
    if test -z "$node"
    then
      echo "\"$name\" does not exist on remote."
      rc=1
      continue
    fi
    local new_sha
    new_sha="$(echo "$node" | jq -r .sha)"
    download_url="${github_download_url_base}/${latest_commit}/${name}"
    # shellcheck disable=SC2059
    printf "Downloading \"$download_url\" to \"$name\" ... " >&2
    curl --silent --fail --output "$file" "$download_url"
    echo "done." >&2
    # shellcheck disable=SC2016
    yq --inplace eval ".last_sha.\"$name\" = \"$new_sha\"" "$state_path"
    mode="$(echo "$node" | jq -r .mode)"
    "$VERBOSE" && echo "  Mode:" "$mode"
    chmod "${mode#???}" "$file"
  done
  return "$rc"
}

# Update task-sh files.
task_task__update() {
  local exclude=":$TASKS_DIR/project.lib.sh:"
  set --
  local file
  for file in "$TASKS_DIR"/*.lib.sh "$TASKS_DIR"/task.sh
  do
    test -r "$file" || continue
    case "$exclude" in
      (*:$file:*) continue;;
    esac
    set -- "$@" "$file"
  done
  subcmd_task__install task task.cmd "$@"
}
