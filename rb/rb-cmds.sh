#!/bin/sh
set -o nounset -o errexit

# Winget // Search results | winget.run https://winget.run/search?query=ruby
# RubyInstaller for Windows // Downloads https://rubyinstaller.org/downloads/
# rbenv (ruby-build) // ruby-build/share/ruby-build at master · rbenv/ruby-build https://github.com/rbenv/ruby-build/tree/master/share/ruby-build
ver=3.2.4
major_minor="$(echo "$ver" | cut -d. -f1-2)"
major_minor_abbrev="$(echo "$major_minor" | tr -d .)"

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

# bin_dir_path="$HOME/.bin"

# shellcheck disable=SC1091
. "$(dirname "$0")"/task.sh

if is_windows
then
  rb_lib_dir_path="c:/Ruby$major_minor_abbrev-$arch"
  if ! type "$rb_lib_dir_path/bin/ruby" >/dev/null 2>&1; then
    # url="https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-$ver-$release/rubyinstaller-$ver-$release-$arch.7z"
    # mkdir -p "$bin_dir_path"
    # temp_dir_path="$(mktemp -d)"
    # curl.exe --fail --location --output "$temp_dir_path"/tmp.7z "$url"
    # (
    #   cd "$bin_dir_path" || exit 1
    #   tar.exe -xf "$temp_dir_path"/tmp.7z
    # )
    # url="https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-$ver-$rubyinstaller_release/rubyinstaller-devkit-$ver-$rubyinstaller_release-$arch.exe"
    # mkdir -p "$bin_dir_path"
    # temp_dir_path="$(mktemp -d)"
    # curl.exe --fail --location --output "$temp_dir_path"/tmp.exe "$url"
    # powershell.exe -Command "Start-Process -Wait -NoNewWindow -FilePath $temp_dir_path/tmp.exe -ArgumentList '/silent /currentuser /dir=$rb_lib_dir_path /tasks=noassocfiles,nomodpath,noridkinstall'"
    winget.exe install "Ruby $major_minor with MSYS2"
  fi
else
  if ! type rbenv >/dev/null 2>&1
  then
    echo "rbenv is not installed." >&2
    exit 1
  fi
  rbenv version | grep -q "$ver" || rbenv local "$ver"
fi

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
      cross_exec rbenv which "$@"
    fi
    PATH="$rb_lib_dir_path/bin:$PATH"
    export PATH
    command -v "$@"
    ;;
  run)
    if type rbenv >/dev/null 2>&1
    then
      cross_exec rbenv exec "$@"
    fi
    PATH="$rb_lib_dir_path/bin:$PATH"
    export PATH
    cross_exec "$@"
    ;;
  *)
    echo "Unknown subcommand: $subcmd" >&2
    exit 1
    ;;
esac
