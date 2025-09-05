# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_6a1f433-false}" && return 0; sourced_6a1f433=true

. ./task.sh

# Tags · knaka/gorun https://github.com/knaka/gorun/tags
: "${version_37475d8:=v0.1.1}"

set_gorun_version() {
  version_37475d8="$1"
}

# Executes Go main package `pkg_name@ver` with arguments and cache the binary to reuse.
subcmd_gorun() {
  local app_dir_path
  app_dir_path="$CACHE_DIR"/app-gorun
  mkdir -p "$app_dir_path"
  local cmd_ext=
  if is_windows
  then
    cmd_ext=.cmd
  fi
  local cmd_base=gorun@"$version_37475d8""$cmd_ext"
  local cmd_path="$app_dir_path"/"$cmd_base"
  if ! test -x "$cmd_path"
  then
    subcmd_curl --fail --location --output "$cmd_path" "https://raw.githubusercontent.com/knaka/gorun/refs/tags/${version_37475d8}/gorun${cmd_ext}"
    chmod +x "$cmd_path"
  fi
  "$cmd_path" "$@"
}
