#!/bin/sh
set -o nounset -o errexit

ghcup_cmd_path="$HOME"/.ghcup/bin/ghcup

if ! test -x "$ghcup_cmd_path"
then
  # Installation - GHCup https://www.haskell.org/ghcup/install/
  if test "$(uname -s)" = Windows_NT
  then
    echo "Not implemented yet." >&2
    exit 1
    # Set-ExecutionPolicy Bypass -Scope Process -Force;[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; try { & ([ScriptBlock]::Create((Invoke-WebRequest https://www.haskell.org/ghcup/sh/bootstrap-haskell.ps1 -UseBasicParsing))) -Interactive=0 -DisableCurl } catch { Write-Error $_ }
  else
    curl -sSf https://get-ghcup.haskell.org | BOOTSTRAP_HASKELL_NONINTERACTIVE=1 BOOTSTRAP_HASKELL_MINIMAL=1 sh
  fi
fi

exec "$ghcup_cmd_path" "$@"
