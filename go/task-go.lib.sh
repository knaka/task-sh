#!/bin/sh

test "${guard_1e6bc22+set}" = set && return 0; guard_1e6bc22=-

. ./task.sh

# Returns the path to the Go root directory.
goroot_path() (
  # All releases - The Go Programming Language https://go.dev/dl/
  required_min_ver=go1.23.1

  if test "${GOROOT+set}" && type "$GOROOT"/bin/go > /dev/null 2>&1 && version_ge "$("$GOROOT"/bin/go env GOVERSION)" "$required_min_ver"
  then
    echo "$GOROOT"
    return
  fi
  if which go > /dev/null 2>&1 && version_ge "$(go env GOVERSION)" "$required_min_ver"
  then
    go env GOROOT
    return
  fi
  for dir_path in \
    "$HOME"/sdk/${required_min_ver} \
    /usr/local/go \
    /usr/local/Cellar/go/* \
    "C:/Program Files"/Go \
    "$HOME"/go
  do
    if type "$dir_path"/bin/go > /dev/null 2>&1 && version_ge "$("$dir_path"/bin/go env GOVERSION)" "$required_min_ver"
    then
      echo "$dir_path"
      return
    fi
  done
  sdk_dir_path="$HOME"/sdk
  goroot="$sdk_dir_path"/${required_min_ver}
  case "$(uname -s)" in
    Linux) goos=linux;;
    Darwin) goos=darwin;;
    Windows_NT) goos=windows;;
    *)
      echo "Unsupported OS: $(uname -s)" >&2
      exit 1;;
  esac
  case "$(uname -m)" in
    arm64) goarch=arm64;;
    x86_64) goarch=amd64;;
    *)
      echo "Unsupported architecture: $(uname -m)" >&2
      exit 1;;
  esac
  mkdir -p "$sdk_dir_path"
  if is_windows
  then
    zip_path="$(temp_dir_path)"/temp.zip
    curl --location -o "$zip_path" "https://go.dev/dl/$required_min_ver.$goos-$goarch.zip"
    (
      cd "$sdk_dir_path" || exit 1
      unzip -q "$zip_path" >&2
    )
  else
    curl --location -o - "https://go.dev/dl/$required_min_ver.$goos-$goarch.tar.gz" | (cd "$sdk_dir_path" || exit 1; tar -xzf -)
  fi
  mv "$sdk_dir_path"/go "$goroot"
  echo "$goroot"
)

# Sets the Go environment. If CGO is required, call `set_unixy_dev_env` also.
set_go_env() {
  first_call 1dc30dd || return 0
  # GOROOT="$(goroot_path)"
  # export GOROOT
  unset GOROOT
  echo Using Go compiler in "$(goroot_path)"/bin >&2
  PATH="$(array_prepend "$PATH" : "$(goroot_path)"/bin)"
  export PATH
}

subcmd_go() { # Run go command.
  set_go_env
  go "$@"
}
