#!/bin/sh
set -o nounset -o errexit

set_dir_sync_ignored "$(dirname "$0")"/.venv

task_install() ( # Install scripts.
  py_bin_dir_path="$HOME"/py-bin
  mkdir -p "$py_bin_dir_path"
  rm -f "$py_bin_dir_path"/*
  for py_file in *.py
  do
    if ! test -r "$py_file"
    then
      continue
    fi
    if echo ",invalid.py," | grep -q ",$py_file,"
    then
      continue
    fi
    py_name="${py_file%.py}"
    if is_windows
    then
      py_bin_file_path="$py_bin_dir_path"/"$py_name.cmd"
      cat <<EOF > "$py_bin_file_path"
@echo off
"$PWD"/task.cmd run "$py_file" %*
EOF
    else
      py_bin_file_path="$py_bin_dir_path"/"$py_name"
      cat <<EOF > "$py_bin_file_path"
#!/bin/sh
exec "$PWD/task" run "$py_file" "\$@"
EOF
      chmod +x "$py_bin_file_path"
    fi
  done
)

subcmd_run() ( # Run a script.
  original_wokrking_dir_path="$PWD"
  cd "$(dirname "$0")"
  cross_exec sh rye-cmd.sh run python lib/run-py.py "$original_wokrking_dir_path" "$@"
)

subcmd_sync() { # Updates the Rye virtualenv.
  cd "$(dirname "$0")"
  cross_exec sh rye-cmd.sh sync "$@"
}
