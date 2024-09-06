#!/bin/sh
set -o nounset -o errexit

# Releases · astral-sh/rye https://github.com/astral-sh/rye/releases
cmd_base="rye"
ver="0.39.0"

# --------------------------------------------------------------------------

exe_ext=
arc_ext=".gz"
case "$(uname -s)" in
  Linux) rust_os="linux" ;;
  Darwin) rust_os="macos" ;;
  Windows_NT)
    exe_ext=".exe"
    arc_ext=".exe"
    rust_os="windows"
    ;;
  *) echo "Unsupported platform" >&2; exit 1 ;;
esac

bin_dir_path="$HOME/.bin"
cmd_path="${bin_dir_path}/${cmd_base}@${ver}${exe_ext}"
if ! test -x "$cmd_path"
then
  mkdir -p "$bin_dir_path"
  case "$(uname -m)" in
    i386 | i486 | i586 | i686) rust_arch="x86" ;;
    x86_64) rust_arch="x86_64" ;;
    arm64) rust_arch="aarch64" ;;
    *) echo "Unsupported architecture" >&2; exit 1 ;;
  esac
  ext=".gz"
  if test "$arc_ext" = ".exe"
  then
    curl --location -o "$cmd_path" \
      "https://github.com/astral-sh/rye/releases/download/${ver}/rye-${rust_arch}-${rust_os}${arc_ext}"
  else
    curl --location -o - "https://github.com/astral-sh/rye/releases/download/${ver}/rye-$rust_arch-$rust_os$ext" |
      gunzip --stdout - > "$cmd_path"
    chmod +x "$cmd_path"
  fi
fi

# --------------------------------------------------------------------------

if test "${1+SET}" != "SET"
then
  echo "Usage: $0 <subcmd> [args...]" >&2
  exit 1
fi

subcmd="$1"
shift

excluded_scrs=",invalid.py,"

install_unix() {
  py_bin_dir_path="$HOME"/py-bin
  mkdir -p "$py_bin_dir_path"
  rm -f "$py_bin_dir_path"/*
  for py_file in *.py
  do
    if echo "$excluded_scrs" | grep -q ",$py_file,"
    then
      continue
    fi
    py_name="${py_file%.py}"
    py_bin_file_path="$py_bin_dir_path"/"$py_name"
    cat <<EOF > "$py_bin_file_path"
#!/bin/sh
exec "$PWD/task" run "$py_file" "\$@"
EOF
    chmod +x "$py_bin_file_path"    
  done
}

install_windows() {
  py_bin_dir_path="$HOME"/py-bin
  mkdir -p "$py_bin_dir_path"
  rm -f "$py_bin_dir_path"/*
  for py_file in *.py
  do
    if echo "$excluded_scrs" | grep -q ",$py_file,"
    then
      continue
    fi
    py_name="${py_file%.py}"
    py_bin_file_path="$py_bin_dir_path"/"$py_name.cmd"
    cat <<EOF > "$py_bin_file_path"
@echo off
"$PWD"/task.cmd run "$py_file" %*
EOF
  done
}

case "$subcmd" in
  install | link)
    case $(uname -s) in
      Linux | Darwin)
        install_unix
        ;;
      Windows_NT)
        install_windows
        ;;
      *)
        exit 1
        ;;
    esac
    ;;
  nop)
    ;;
  rye)
    exec "$cmd_path" "$@"
    ;;
  run)
    original_wokrking_dir_path="$PWD"
    script_dir_path="$(dirname "$0")"
    cd "$script_dir_path"
    exec "$cmd_path" run python lib/run-py.py "$original_wokrking_dir_path" "$@"
    ;;
  sync)
    exec "$cmd_path" sync "$@"
    ;;
  *)
    ;;
esac
