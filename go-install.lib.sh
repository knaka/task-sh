# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_e080e29-false}" && return 0; sourced_e080e29=true

. ./task.sh
. ./go.lib.sh

# Run executable package of Go with arguments. If the env var $SETUP_PATH_ONLY is set, this prepends the path to the command and returns.
run_go_pkg() {
  local pkg_name_ver="$1"
  shift
  local cmd_ver="${pkg_name_ver##*/}"
  local cmd="${cmd_ver%@*}"
  local ver="${cmd_ver#*@}"
  local app_dir_path="$CACHE_DIR"/"$cmd"@"$ver"
  mkdir -p "$app_dir_path"
  local cmd_path="$app_dir_path/$cmd$exe_ext"
  if ! command -v "$cmd_path" >/dev/null 2>&1
  then
    GOBIN="$app_dir_path" go install "$pkg_name_ver"
  fi
  if test "${SETUP_PATH_ONLY+set}" = set
  then
    export PATH="$app_dir_path:$PATH"
    return 0
  fi
  invoke "$cmd_path" "$@"
}
