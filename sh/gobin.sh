#!/bin/sh

gobin_cmd_path="$HOME"/go/bin/gobin
if ! type "$gobin_cmd_path" > /dev/null 2>&1
then
  "$HOME"/src/go/task go install github.com/knaka/gobin/cmd/gobin@latest
  echo ?
fi
exec "$gobin_cmd_path" "$@"
