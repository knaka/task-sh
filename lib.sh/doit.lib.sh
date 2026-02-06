# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_5f91846-false}" && return 0; sourced_5f91846=true

type before_source >/dev/null 2>&1 || . ./min.lib.sh
before_source .
after_source

doit_sub1() {
  echo Doit sub1
}

doit_sub2() {
  echo Doit sub2
}
