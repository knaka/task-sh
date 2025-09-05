# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_dfcd90e-false}" && return 0; sourced_dfcd90e=true

. ./task.sh

# if test "${GITHUB_ACTIONS:-}" != "true"
# then
#   set_sync_ignored "$SCRIPT_DIR"/.git
# fi

# Run git command.
subcmd_git() (
  chdir_script
  git_cmd_path="$(command -v git)"
  if ! test -r .git/HEAD
  then
    "$git_cmd_path" init
    set_sync_ignored "$SCRIPT_DIR"/.git
    "$git_cmd_path" remote add origin git@github.com:knaka/src.git
    "$git_cmd_path" fetch origin main
    "$git_cmd_path" reset --hard origin/main
    "$git_cmd_path" branch --set-upstream-to=origin/main main
  fi
  "$git_cmd_path" "$@"
)
