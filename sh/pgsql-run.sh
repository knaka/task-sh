#!/bin/sh
set -o nounset -o errexit

# EDB: Open-Source, Enterprise Postgres Database Management https://www.enterprisedb.com/download-postgresql-binaries
ver=16.4-1

if test "${1+set}" != set
then
   echo "Usage: $0 <command> [args...]" >&2
  exit 1
fi

cmd_name="$1"
shift
if type "$cmd_name" >/dev/null 2>&1
then
  exec "$cmd_name" "$@"
fi

bin_dir_path="$HOME"/.bin
mkdir -p "$bin_dir_path"
sub_dir_path="$bin_dir_path"/pgsql-"$ver"
cmd_bin_dir_path="$sub_dir_path"/bin
exe_ext=
if ! test -d "$cmd_bin_dir_path"
then
  case "$(uname -s)" in
    Darwin)
      os_arch=osx
      ;;
    Windows_NT)
      exe_ext=.exe
      case "$(uname -m)" in
        x86_64)
          os_arch=windows-x64
          ;;
        *)
          echo "Unsupported architecture: $(uname -m)" >&2
          exit 1
          ;;
      esac
      ;;
    *)
      echo "Unsupported OS: $(uname -s)" >&2
      exit 1
      ;;
  esac


  url="https://get.enterprisedb.com/postgresql/postgresql-$ver-$os_arch-binaries.zip"
  curl$exe_ext --fail --location --output - "$url" | (cd "$bin_dir_path" && tar$exe_ext -xf - && mv pgsql pgsql-"$ver")
fi

exec "$cmd_bin_dir_path"/"$cmd_name" "$@"
