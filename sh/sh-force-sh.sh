#!/usr/bin/env sh
# vim: set filetype=sh :
# shellcheck shell=sh
test "${sourced_0f9d2de-}" = true && return 0; sourced_0f9d2de=true
set -o nounset -o errexit
# set -o xtrace # For debugging

ensure_executed_with_posix_sh() {
  if test "${SH+set}" = set
  then
    return 0
  fi
  if test "${BASH+set}" = set
  then
    # shellcheck disable=SC3057
    if test "${BASH_VERSION:0:1}" -ge 4
    then
      return 0
    fi
  fi
  for SH in /bin/ash /bin/dash
  do
    if test -x "$SH"
    then
      export SH
      exec "$SH" "$@"
    fi
  done
  echo "No appropriate shell found" >&2
  return 1
}

ensure_executed_with_posix_sh "$0" "$@"

echo 1e0aa9d "$0" >&2
