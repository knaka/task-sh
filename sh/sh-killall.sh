#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_27695c0-}" = true && return 0; sourced_27695c0=true
set -o nounset -o errexit

pids=

kill_all_children() {
  local rc=$?
  local pid
  for pid in $pids
  do
    kill "$pid" || :
    echo Killed >&2
  done
  exit $rc
}

trap kill_all_children EXIT

(
  while true
  do
    echo hello
    sleep 1
  done
) &
pids="$pids$! "

(
  while true
  do
    echo world
    sleep 1
  done
) &
pids="$pids$! "

bg_exec() {
  local stdout=
  local errout=
  local both=
  OPTIND=1; while getopts s:e:b: OPT
  do
    case $OPT in
      s) stdout=$OPTARG ;;
      e) errout=$OPTARG ;;
      b) both=$OPTARG ;;
      *) return 1 ;;
    esac
  done
  shift $((OPTIND - 1))
  if test -n "$stdout"
  then
    "$@" >"$stdout" </dev/null &
  elif test -n "$errout"
  then
    "$@" 2>"$errout" </dev/null &
  elif test -n "$both"
  then
    "$@" >"$both" 2>&1 </dev/null &
  else
    "$@" </dev/null &
  fi
  pid=$!
  pids="${pids:+$pids }$pid"
  echo $pid: "$@" >&2
}

bg_exec -s /tmp/out.log date

# pids="${pids:+$pids }$!"

echo a19faaa $!

# pstree

sleep 3
