#!/bin/sh
set -o nounset -o errexit

# Downloads https://rubyinstaller.org/downloads/
ver=3.3.4
release=1

cd "$(dirname "$0")" || exit 1

cleanup() {
  if test "${temp_dir_path+set}" = set
  then
    rm -rf "$temp_dir_path"
  fi
}

trap cleanup EXIT

case "$(uname -m)"
in
  x86_64)
    arch=x64
    ;;
  *)
    echo "$(uname -m) is not supported." >&2
    ;;
esac

bin_dir_path="$HOME/.bin"

case "$(uname -s)"
in
  Windows_NT)
    rb_lib_dir_path="$bin_dir_path/rubyinstaller-$ver-$release-$arch"
    if ! type "$rb_lib_dir_path/bin/ruby" >/dev/null 2>&1; then
      url="https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-$ver-$minot/rubyinstaller-$ver-$release-$arch.7z"
      mkdir -p "$bin_dir_path"
      temp_dir_path="$(mktemp -d)"
      curl.exe --fail --location --output "$temp_dir_path"/tmp.7z "$url"
      (
        cd "$bin_dir_path" || exit 1
        tar.exe -xf "$temp_dir_path"/tmp.7z
      )
    fi
    ;;
  *)
    if ! type rbenv >/dev/null 2>&1
    then
      echo "rbenv is not installed." >&2
      exit 1
    fi
    rbenv version | grep -q "$ver" || rbenv local "$ver"
    ;;
esac

if ! test "${1+set}" = set
then
  echo "Usage: $0 command [args...]" >&2
  exit 1
fi

subcmd="$1"
shift

case "$subcmd"
in
  path)
    if type rbenv >/dev/null 2>&1
    then
      dirname "$(rbenv which ruby)"
      exit 0
    fi
    echo "$rb_lib_dir_path/bin"
    ;;
  which)
    if type rbenv >/dev/null 2>&1
    then
      exec rbenv which "$@"
    fi
    PATH="$rb_lib_dir_path/bin:$PATH" command -v "$@"
    ;;
  run)
    if type rbenv >/dev/null 2>&1
    then
      exec rbenv exec "$@"
    fi
    PATH="$rb_lib_dir_path/bin:$PATH" exec "$@"
    ;;
  *)
    echo "Unknown subcommand: $subcmd" >&2
    exit 1
    ;;
esac
