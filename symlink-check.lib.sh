# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_9e5d44a-false}" && return 0; sourced_9e5d44a=true

. ./task.sh

ln -sf target "$TEMP_DIR"/symlink
if ! test -L "$TEMP_DIR"/symlink
then
  echo "Failed to create symlink." >&2
  if is_windows
  then
    echo "To enable symlink creation on Windows, enable Developer Mode or run as Administrator." >&2
  fi
  exit 1
fi
