#!/bin/sh

cleanup() {
  if test "${tmp_dir_path+set}" = set
  then
    rm -rf "$tmp_dir_path"
  fi
}

trap cleanup EXIT

gobin_cmd_path="$HOME"/go/bin/gobin-cmd
if ! type "$gobin_cmd_path" > /dev/null 2>&1
then
  tmp_dir_path=$(mktemp -d)
  GOBIN="$tmp_dir_path" "$(dirname "$0")"/../go/task go install github.com/knaka/gobin/cmd/gobin@latest
  mv "$tmp_dir_path"/gobin "$gobin_cmd_path"
fi
exec "$gobin_cmd_path" "$@"
