#!/usr/bin/env dash
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_9f4452e-}" = true && return 0; sourced_9f4452e=true
set -o nounset -o errexit

TEMP_DIR="$(mktemp -d)"
# shellcheck disable=SC2064
trap "rm -fr '$TEMP_DIR'" EXIT

# Chain traps not to overwrite the previous trap.
# shellcheck disable=SC2064
chaintrap() {
  local stmts_file="$TEMP_DIR"/b6a5748."$2"
  local stmts_bak_file="$TEMP_DIR"/347803f
  if test -f "$stmts_file"
  then
    cp "$stmts_file" "$stmts_bak_file"
  else
    touch "$stmts_bak_file"
  fi
  echo "{ $1; };" >"$stmts_file"
  cat "$stmts_bak_file" >>"$stmts_file"
  trap ". '$stmts_file'; rm -fr '$TEMP_DIR'" "$2"
  # cat -n "$stmts_file" >&2
  # echo >&2
}

chaintrap 'echo Foo' EXIT
chaintrap 'echo Bar' EXIT
chaintrap 'echo Baz' EXIT

chaintrap 'echo Hoge' INT
chaintrap 'echo Fuga' INT
