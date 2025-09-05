# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_17de8d0-false}" && return 0; sourced_17de8d0=true

. ./task.sh

# Run the gobin command.
subcmd_gobin() {
  if ! test -r Gobinfile
  then
    echo "Gobinfile not found in the project root." >&2
    exit 1
  fi
  local bin_dir_path="$HOME"/.bin
  local app_dir_path="$bin_dir_path"/gobin
  local cmd_ext=
  if is_windows
  then
    cmd_ext=".cmd"
  fi
  if ! test -x "$app_dir_path"/cmd-gobin$cmd_ext
  then
    mkdir -p "$app_dir_path"
    subcmd_curl --fail --location --output "$app_dir_path"/cmd-gobin$cmd_ext https://raw.githubusercontent.com/knaka/gobin/main/bootstrap/cmd-gobin$cmd_ext
    chmod +x "$app_dir_path"/cmd-gobin$cmd_ext
  fi
  "$app_dir_path"/cmd-gobin$cmd_ext "$@"
}
