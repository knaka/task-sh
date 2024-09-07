#!/bin/sh

# All releases - The Go Programming Language https://go.dev/dl/
ver=1.23.0

is_windows() {
  test "$(uname -s)" = "Windows_NT" && return 0 || return 1
}

# gobin returns the path to the Go bin directory.
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
}

go_cmd_result=""

go_cmd() {
  if test -n "$go_cmd_result"
  then
    echo "$go_cmd_result"
    return
  fi
  go_cmd_result="$(gobin)"/go
  echo "$go_cmd_result"
}

subcmd_go() { # Run go command.
  exec "$(go_cmd)" "$@"
}

task_install() { # Install updated Go tools.
  cd "$(dirname "$0")" || exit 1
  go_bin_dir_path="$HOME"/go-bin
  mkdir -p "$go_bin_dir_path"
  ext=
  if is_windows
  then
    ext=.exe
  fi
  for go_file in *.go
  do
    if ! test -r "$go_file"
    then
      continue
    fi
    name=$(basename "$go_file" .go)
    target_bin_path="$go_bin_dir_path"/"$name$ext"
    if type "$target_bin_path" > /dev/null 2>&1 &&
      test -n "$(find "$target_bin_path" -newer "$go_file" 2>/dev/null)"
    then
      continue
    fi
    "$(go_cmd)" build -o "$target_bin_path" ./"$go_file"
    echo Built "$target_bin_path" >&2
  done
}

for path in .idea .git
do
  if test -d "$(dirname "$0")""$path"
  then
    set_path_sync_ignored "$(dirname "$0")""$path"
  fi
done
