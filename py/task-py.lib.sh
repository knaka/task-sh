#!/bin/sh
set -o nounset -o errexit

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

task_install() { # Install scripts.
  if is_windows
  then
    install_windows
  else
    install_unix
  fi
}

subcmd_run() ( # Run a script.
  original_wokrking_dir_path="$PWD"
  cd "$(dirname "$0")"
  cross_exec sh rye-cmd.sh run python lib/run-py.py "$original_wokrking_dir_path" "$@"
)

subcmd_sync() { # Updates the Rye virtualenv.
  cd "$(dirname "$0")"
  cross_exec sh rye-cmd.sh sync "$@"
}
