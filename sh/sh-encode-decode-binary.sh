#!/usr/bin/env dash
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_f98ab98-}" = true && return 0; sourced_f98ab98=true
set -o nounset -o errexit

hex_dump() {
  od -A n -t x1 -v | xargs printf "%s "
}

hex_restore() {
  xargs printf "%s\n" | awk '{ printf("%c",  int("0x" $1)) }'
}

oct_dump() {
  od -A n -t o1 -v | xargs printf "%04s "
}

oct_restore() {
  xargs printf '\\\\%s\n' | xargs printf "%b"
}

echo "hello" | oct_dump | oct_restore

temp_dir_path="$(mktemp -d)"
# bin_file_path=/bin/bash
bin_file_path=/Users/knaka/repos/github.com/knaka/gcsvc/src-pages/test.png
# -A n: No address
# -t x1: Output format in hexadecimal
# -v: Show all input data
# od -A n -t x1 -v <"$bin_file_path" | xargs printf "%s " >"$temp_dir_path"/hex
hex_dump <"$bin_file_path" >"$temp_dir_path"/hex
# cat "$temp_dir_path"/hex
# xargs printf "%s\n" <"$temp_dir_path"/hex | awk '{ printf("%c",  int("0x" $1)) }' >"$temp_dir_path"/bin
hex_restore <"$temp_dir_path"/hex >"$temp_dir_path"/bin

echo "Original:"
printf "  "
ls -l "$bin_file_path"
printf "  "
shasum "$bin_file_path"

echo "Decoded:"
printf "  "
ls -l "$temp_dir_path"/bin
printf "  "
shasum "$temp_dir_path"/bin

cat <<EOF >"$temp_dir_path"/input
hello
foo
bar
bar
baz
world
baz
EOF

cat <<EOF >"$temp_dir_path"/pattern
foo
bar
bar
baz
EOF

hex_dump <"$temp_dir_path"/input | sed -e "s/$(hex_dump <"$temp_dir_path"/pattern)//" | hex_restore

rm -fr "$temp_dir_path"