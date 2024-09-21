#!/bin/sh
set -o nounset -o errexit

# shellcheck disable=SC1091
. "$(dirname "$0")"/task.sh

if is_windows
then
  ghcup_cmd_path="$HOME"/scoop/shims/ghcup
  # Installation - Scoop https://scoop.sh/
  if ! type scoop > /dev/null 2>&1
  then
    printf "Scoop is not installed. Install? (y/N): "
    read -r yn
    case "$yn" in
      [yY]*) ;;
      *) exit 0 ;;
    esac
    powershell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser; Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression"
  fi
  if ! type "$ghcup_cmd_path" > /dev/null 2>&1
  then
    scoop install ghcup
  fi
else
  ghcup_cmd_path="$HOME"/.ghcup/bin/ghcup
  if ! test -x "$ghcup_cmd_path"
  then
    curl -sSf https://get-ghcup.haskell.org | BOOTSTRAP_HASKELL_NONINTERACTIVE=1 BOOTSTRAP_HASKELL_MINIMAL=1 sh
  fi
fi

exec "$ghcup_cmd_path" "$@"
