#!/bin/sh
test "${guard_fbaba3d+set}" = set && return 0; guard_fbaba3d=x
set -o nounset -o errexit

. ./task-bun.lib.sh
. ./assert.lib.sh

test_bun() {
  subcmd_bun --help >/dev/null
}

. ./task-proto.lib.sh

test_archive() {
  assert_eq "proto_cli-x86_64-unknown-linux-gnu.tar.xz" "$(echo_proto_arc_filename x86_64 Linux)"
  assert_eq "proto_cli-aarch64-apple-darwin.tar.xz" "$(echo_proto_arc_filename arm64 Darwin)"
  assert_eq "proto_cli-x86_64-pc-windows-msvc.zip" "$(echo_proto_arc_filename x86_64 Windows_NT)"

  assert_true echo_proto_arc_filename arm64 Darwin >/dev/null
  assert_false echo_proto_arc_filename arm64 FreeBSD >/dev/null
  assert_false echo_proto_arc_filename m68k Darwin >/dev/null
}
