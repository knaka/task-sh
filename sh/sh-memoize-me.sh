#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_9ff48fc-false}" && return 0; sourced_9ff48fc=true
set -o nounset -o errexit

set -- "$PWD" "${0%/*}" "$@"; test "$2" != "$0" && cd "$2"
. ./task.sh
cd "$1"; shift 2

cache_file_path=

begin_memoize() {
  cache_file_path="$TEMP_DIR"/cache-"$(oct_encode "$*")"
  if test -r "$cache_file_path"
  then
    echo "Cache $cache_file_path exists." >&2
    cat "$cache_file_path"
    return 1
  fi
  echo "Caching to $cache_file_path..." >&2
  exec 9>&1
  exec >"$cache_file_path"
}

end_memoize() {
  exec 1>&9 9>&-
  if test -r "$cache_file_path"
  then
    cat "$cache_file_path"
  fi
}

foo() {
  begin_memoize 8701441 "$@" || return 0
  echo Executing heavy function foo_sub. >&2
  echo FOO1
  echo "$@"
  echo FOO2
  sleep 3
  end_memoize
}

bar_sub() {
  echo BAR1
  echo "$@"
  echo BAR2
}

bar() {
  begin_memoize 1653899 "$@" || return 0
  bar_sub "$@"
  end_memoize
}

sh_memoize_me() {
  foo aaa bbb
  bar xxx yyy
  foo aaa bbb
  foo zzz zzz
}

case "${0##*/}" in
  (sh-memoize-me.sh|sh-memoize-me)
    set -o nounset -o errexit
    sh_memoize_me "$@"
    ;;
esac
