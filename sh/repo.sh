#!/bin/bash
set -o nounset -o errexit -o pipefail

cmd=ghq

# サブコマンド

if test "${1+SET}" = "SET"
then
  case "$1" in
    st|stat)
      exec "$cmd" root
      ;;
  esac
  # repo-～ のコマンドがあればそっちへ
  if which "$0"-"$1" > /dev/null 2>&1
  then
    sub_cmd="$0"-"$1"
    shift
    exec "${sub_cmd}" "$@"
  fi

  exec $cmd "$@"
fi

# サブコマンドの指定がなければ、レポジトリ一覧

repo=$("$cmd" list | peco)
if test -z "${repo}"
then
  exit 1
fi
echo "$("$cmd" root)"/"${repo}"
