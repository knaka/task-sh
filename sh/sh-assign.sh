#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_0151acf-false}" && return 0; sourced_0151acf=true

foo() {
  export BAR="${BAR:=bar}"
  echo d: "$BAR" >&2
}

sh_assign() {
  export BAR=hoge
  foo
}

case "${0##*/}" in
  (sh-assign.sh|sh-assign)
    set -o nounset -o errexit
    sh_assign "$@"
    ;;
esac
