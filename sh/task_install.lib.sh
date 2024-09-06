#!/bin/sh

# Scripts not to be installed.
excluded_scripts=",task.sh,"
for file in *.lib.sh
do
  if ! test -r "$file"
  then
    continue
  fi
  excluded_scripts="$excluded_scripts,$file,"
done

is_windows=$(test "$(uname -s)" = Windows_NT && echo true || echo false)

_install() {
  _is_windows=$1
  sh_bin_dir_path="$HOME"/sh-bin
  mkdir -p "$sh_bin_dir_path"
  rm -f "$sh_bin_dir_path"/*
  for sh_file in *.sh
  do
    if echo "$excluded_scripts" | grep -q ",$sh_file,"
    then
      continue
    fi
    sh_name="${sh_file%.sh}"
    if $_is_windows
    then
      cat task.cmd > "$sh_bin_dir_path"/"$sh_name".cmd
    else 
      ln -s "$PWD/task" "$sh_bin_dir_path"/"$sh_name"
    fi
  done
  if $_is_windows
  then
    cat <<EOF > "$sh_bin_dir_path"/.env.sh.cmd
set sh_dir_path=$PWD
EOF
  else
    cat <<EOF > "$sh_bin_dir_path"/.env.sh
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

: "${script_dir_path:=}"

task_install() { # Install scripts to sh-bin/ directory.
  cd "$script_dir_path" || exit 1
  if $is_windows
  then
    install_windows
  else
    install_unix
  fi
}
