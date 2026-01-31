# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_de46f52-false}" && return 0; sourced_de46f52=true

. ./task.sh

# All releases - The Go Programming Language https://go.dev/dl/
go_required_min_ver_bb972aa=go1.23.1

set_go_required_min_ver() {
  go_required_min_ver_bb972aa="$1"
}

write_go_dir_paths() {
  # $GOROOT
  if test "${GOROOT+set}" = set
  then
    echo "$GOROOT"
  fi
  # `go` external command. Use `which` to search because `go` function exists.
  if which go >/dev/null 2>&1
  then
    command go env GOROOT
  fi
  # System-wide installation
  if is_windows
  then
    echo "C:/Program Files/Go"
  else
    echo "/usr/local/go"
  fi
  # Automatically installed SDKs
  find "$HOME"/sdk -maxdepth 1 -type d -name 'go*' 2>/dev/null | sort -r
}

search_sufficient_go_root() {
  write_go_dir_paths \
  | while read -r go_dir_path
    do
      if command -v "$go_dir_path"/bin/go >/dev/null 2>&1
      then
        if version_ge "$(GOTOOLCHAIN=local "$go_dir_path"/bin/go env GOVERSION)" "$go_required_min_ver_bb972aa"
        then
          echo "$go_dir_path"
          break
        fi
      fi
    done
}

# Returns the path to the Go root directory.
write_goroot_path() {
  local goroot
  goroot="$(search_sufficient_go_root)"
  if test -n "$goroot"
  then
    echo "$goroot"
    return
  fi

  # If no Go installation is found, install the required version.
  local sdk_dir_path="$HOME"/sdk
  goroot="$sdk_dir_path"/${go_required_min_ver_bb972aa}
  local goos
  case "$(uname -s)" in
    (Linux) goos=linux;;
    (Darwin) goos=darwin;;
    (Windows_NT) goos=windows;;
    (*)
      echo "Unsupported OS: $(uname -s)" >&2
      return 1
      ;;
  esac
  local goarch
  case "$(uname -m)" in
    (arm64) goarch=arm64;;
    (x86_64) goarch=amd64;;
    (*)
      echo "Unsupported architecture: $(uname -m)" >&2
      return 1
      ;;
  esac
  mkdir -p "$sdk_dir_path"
  rm -fr "$sdk_dir_path"/go
  if is_windows
  then
    zip_path="$TEMP_DIR"/temp.zip
    curl --location -o "$zip_path" "https://go.dev/dl/$go_required_min_ver_bb972aa.$goos-$goarch.zip"
    (
      cd "$sdk_dir_path" || exit 1
      unzip -q "$zip_path" >&2
    )
  else
    curl --location -o - "https://go.dev/dl/$go_required_min_ver_bb972aa.$goos-$goarch.tar.gz" | (cd "$sdk_dir_path" || exit 1; tar -xzf -)
  fi
  mv "$sdk_dir_path"/go "$goroot"
  echo "$goroot"
}

# Sets the Go environment. If CGO is required, call `set_unixy_dev_env` also.
set_go_env() {
  first_call 1dc30dd || return 0
  unset GOROOT
  echo Using Go toolchain in "$(write_goroot_path)" >&2
  PATH="$(write_goroot_path)"/bin:"$PATH"
  export PATH
}

go() {
  set_go_env
  invoke go "$@"
}

# Run go command.
subcmd_go() {
  go "$@"
}

# Run gofmt command.
subcmd_gofmt() {
  set_go_env
  invoke gofmt "$@"
}

# Run Go tests.
subcmd_go__test() {
  if test $# = 0
  then
    set -- ./...
  fi
  go test "$@"
}
