# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_0cbefda-false}" && return 0; sourced_0cbefda=true

. ./task.sh
. ./go-install.lib.sh

# goyacc command versions - golang.org/x/tools/cmd/goyacc - Go Packages https://pkg.go.dev/golang.org/x/tools/cmd/goyacc?tab=versions
ver_goyacc_bd0cd09=v0.36.0

goyacc() {
  run_go_pkg golang.org/x/tools/cmd/goyacc@"$ver_goyacc_bd0cd09" "$@"
}

# Run goyacc(1)
subcmd_goyacc() {
  goyacc "$@"
}
