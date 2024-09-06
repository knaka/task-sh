#!/bin/sh
set -o nounset -o errexit

# All releases - The Go Programming Language https://go.dev/dl/
ver=1.23.0

# get_gobin returns the path to the Go bin directory.
gobin() {
  if test "${GOBIN+SET}" = "SET"
  then
    echo "$GOBIN"
    return
  fi
  if test "${GOROOT+SET}" = "SET"
  then
    echo "$GOROOT"/bin
    return
  fi
  if test "${GOPATH+SET}" = "SET"
  then
    echo "$GOPATH"/bin
    return
  fi
  if which go > /dev/null 2>&1
  then
    echo "$(go env GOROOT)"/bin
    return
  fi
  for dir_path in \
    "$HOME"/sdk/go${ver} \
    /usr/local/go \
    /usr/local/Cellar/go/* \
    "/Program Files"/Go \
    "$HOME"/go
  do
    if type "$dir_path"/bin/go > /dev/null 2>&1
    then
      echo "$dir_path"/bin
      return
    fi
  done
  _sdk_dir_path="$HOME"/sdk
  _goroot="$_sdk_dir_path"/go${ver}
  case "$(uname -s)" in
    Linux) _goos=linux;;
    Darwin) _goos=darwin;;
    Windows_NT) _goos=windows;;
    *) exit 1;;
  esac
  case "$(uname -m)" in
    arm64) _goarch=arm64;;
    x86_64) _goarch=amd64;;
    *) exit 1;;
  esac
  mkdir -p "$_sdk_dir_path"
  curl --location -o - "https://go.dev/dl/go$ver.$_goos-$_goarch.tar.gz" | (cd "$_sdk_dir_path"; tar -xzf -)
  mv "$_sdk_dir_path"/go "$_goroot"
  echo "$_goroot"/bin
}

script_dir_path="$(dirname "$0")"
if test "${1+SET}" != "SET"
then
  exit 1
fi
subcmd="$1"
shift
cmd_path="$(gobin)"/go
case "$subcmd" in
  go)
    exec "$cmd_path" "$@"
    ;;
  install)
    go_bin_dir_path="$HOME"/go-bin
    mkdir -p "$go_bin_dir_path"
    rm -f "$go_bin_dir_path"/*
    cd "$script_dir_path"
    for go_file in *.go
    do
      if ! test -r "$go_file"
      then
        continue
      fi
      name=$(basename "$go_file" .go)
      "$cmd_path" build -o "$go_bin_dir_path"/"$name" ./"$go_file"
    done
    ;;
  *)
    exit 1
    ;;
esac
