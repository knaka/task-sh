#!/bin/sh
test "${guard_b6c071a+set}" = set && return 0; guard_b6c071a=-

. ./task.sh

subcmd_install() ( # Install shell scripts.
  excluded_scripts=":task.sh:"
  for file in task-*.sh *.lib.sh
  do
    if ! test -r "$file"
    then
      continue
    fi
    excluded_scripts="$excluded_scripts:$file:"
  done
  sh_bin_dir_path="$HOME"/sh-bin
  mkdir -p "$sh_bin_dir_path"
  rm -f "$sh_bin_dir_path"/*
  mkdir -p "$sh_bin_dir_path"/tasks
  rm -f "$sh_bin_dir_path"/tasks/*
  for sh_file in *.sh
  do
    if echo "$excluded_scripts" | grep -q ":$sh_file:"
    then
      continue
    fi
    sh_name="${sh_file%.sh}"
    if is_windows
    then
      cat task.cmd > "$sh_bin_dir_path"/"$sh_name".cmd
    else 
      ln -s "$PWD/task" "$sh_bin_dir_path"/"$sh_name"
    fi
    cat <<EOF >"$sh_bin_dir_path"/tasks/"$sh_name".sh
#!/usr/bin/env sh
exec "$SH" "$PROJECT_DIR"/"$sh_file" "\$@"
EOF
  done
  if is_windows
  then
    cat <<EOF > "$sh_bin_dir_path"/.env.sh.cmd
set sh_dir_path=$PWD
EOF
  else
    cat <<-EOF > "$sh_bin_dir_path"/.env.sh
sh_dir_path="$PWD"
EOF
  fi
)
