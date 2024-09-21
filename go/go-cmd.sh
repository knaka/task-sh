#!/bin/sh
set -o nounset -o errexit

# All releases - The Go Programming Language https://go.dev/dl/
ver=1.23.0

if ! realpath "$(pwd)" | grep -q "^$(realpath "$(dirname "$0")")"
then
  echo "Please run this script in the same directory as the script." >&2
  exit 1
fi

. "$(dirname "$0")"/task.sh

# gobin returns the path to the Go bin directory.
gobin() (
  if test "${GOROOT+SET}" = "SET"
  then
    echo "$GOROOT"/bin
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
  if is_windows
  then
    _temp_dir_path=$(mktemp -d)
    zip_path="$_temp_dir_path"/temp.zip
    curl --location -o "$zip_path" "https://go.dev/dl/go$ver.$_goos-$_goarch.zip"
    (cd "$_sdk_dir_path" || exit 1; unzip -q "$zip_path" >&2)
    rm -fr "$_temp_dir_path"
  else
    curl --location -o - "https://go.dev/dl/go$ver.$_goos-$_goarch.tar.gz" | (cd "$_sdk_dir_path" || exit 1; tar -xzf -)
  fi
  mv "$_sdk_dir_path"/go "$_goroot"
  echo "$_goroot"/bin
)

go_cmd_path="$(gobin)"/go
exec "$go_cmd_path" "$@"
