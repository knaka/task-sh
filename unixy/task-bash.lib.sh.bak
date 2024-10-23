#!/bin/sh

msys_bin_dir_path_result=

msys_bin_dir_path() {
  ver=20240727
  if test -z "$msys_bin_dir_path_result"
  then
    bin_dir_path="$HOME"/.bin
    mkdir -p "$bin_dir_path"
    case "$(uname -m)" in
      i386|i486|i586|i686)
        exit 1
        ;;
      x86_64)
        arch=x86_64
        dir_name=msys64
        ;;
      *) exit 1;;
    esac
    msys_dir_path="$bin_dir_path"/"$dir_name-$ver"
    if ! test -d "$msys_dir_path"
    then
      url="https://repo.msys2.org/distrib/${arch}/msys2-base-${arch}-${ver}.tar.xz"
      curl.exe --fail --location -o - "$url" | (cd "$bin_dir_path" || exit 1; tar -xJf -; mv "$dir_name" "$dir_name-$ver")
    fi
    msys_bin_dir_path_result="$msys_dir_path"/usr/bin
  fi
  echo "$msys_bin_dir_path_result"
}

subcmd_run() {
  script_name="$1"
  shift
  script_path="$(realpath "$script_name")"
  if test "$(uname -s)" = "Windows_NT"
  then
    PATH="$(msys_bin_dir_path)":"$PATH"
    export PATH
    exec "$(msys_bin_dir_path)"/bash.exe "$script_path" "$@"
  fi
  exec /bin/bash "$script_path" "$@"
}

# Scripts not to be installed.
excluded_scripts=",,"
for file in *.lib.bash
do
  if ! test -r "$file"
  then
    continue
  fi
  excluded_scripts="$excluded_scripts,$file,"
done

_install() {
  _is_windows=$1
  bash_bin_dir_path="$HOME"/bash-bin
  mkdir -p "$bash_bin_dir_path"
  rm -f "$bash_bin_dir_path"/*
  for bash_file in *.bash
  do
    if echo "$excluded_scripts" | grep -q ",$bash_file,"
    then
      continue
    fi
    bash_name="${bash_file%.bash}"
    if $_is_windows
    then
      cat task.cmd > "$bash_bin_dir_path"/"$bash_name".cmd
    else 
      ln -s "$PWD/task" "$bash_bin_dir_path"/"$bash_name"
    fi
  done
  if $_is_windows
  then
    cat <<EOF > "$bash_bin_dir_path"/.env.sh.cmd
set sh_dir_path=$PWD
EOF
  else
    cat <<EOF > "$bash_bin_dir_path"/.env.sh
sh_dir_path="$PWD"
EOF
  fi
}

install_unix() {
  _install false
}

install_windows() {
  _install true
}

is_windows=$(test "$(uname -s)" = Windows_NT && echo true || echo false)

task_install() { # Install scripts to bash-bin/ directory.
  cd "$(dirname "$0")" || exit 1
  if $is_windows
  then
    install_windows
  else
    install_unix
  fi
}
