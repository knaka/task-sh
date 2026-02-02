# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_de46f52-false}" && return 0; sourced_de46f52=true

. ./task.sh

go() {
  mise exec go -- go "$@"
}

# Run go command.
subcmd_go() {
  go "$@"
}

gofmt() {
  mise exec go -- gofmt "$@"
}

# Run gofmt command.
subcmd_gofmt() {
  gofmt "$@"
}

# Run Go tests.
subcmd_go__test() {
  if test $# = 0
  then
    set -- ./...
  fi
  go test "$@"
}
