#!/usr/bin/env dash
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_9f4452e-}" = true && return 0; sourced_9f4452e=true
set -o nounset -o errexit

TEMP_DIR="$(mktemp -d)"
# shellcheck disable=SC2064
trap "rm -fr '$TEMP_DIR'" EXIT

readonly stmts_file_base="$TEMP_DIR"/b6a5748

# Chain traps not to overwrite the previous trap.
# shellcheck disable=SC2064
chaintrap() {
  local stmts="$1"
  shift 
  local stmts_bak_file="$TEMP_DIR"/347803f
  local sigspec
  for sigspec in "$@"
  do
    sigspec=$(echo "$sigspec" | tr '[:lower:]' '[:upper:]')
    local stmts_file="$stmts_file_base"-"$sigspec"
    if test -f "$stmts_file"
    then
      cp "$stmts_file" "$stmts_bak_file"
    else
      touch "$stmts_bak_file"
    fi
    echo "{ $stmts; };" >"$stmts_file"
    cat "$stmts_bak_file" >>"$stmts_file"
    # shellcheck disable=SC2154
    trap "rc=\$?; . '$stmts_file'; rm -fr '$TEMP_DIR'; exit \$rc" "$sigspec"
  done
}

on_exit() {
  local stmts_file="$stmts_file_base"-EXIT
  # shellcheck disable=SC1090
  test -f "$stmts_file" && . "$stmts_file"
}

chaintrap 'echo Foo' INT EXIT USR1
chaintrap 'echo Bar' EXIT
chaintrap 'echo Baz' EXIT

chaintrap 'echo Hoge' INT
chaintrap 'echo Fuga' INT

false

# # Before `exec`, call `on_exit` to run the trap.
# on_exit
# exec /bin/echo hello
