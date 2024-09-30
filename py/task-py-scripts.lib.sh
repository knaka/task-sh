#!/bin/sh
set -o nounset -o errexit

test "${guard_9ac5215+set}" = set && return 0; guard_9ac5215=-

. task.sh
. task-rye.lib.sh

set_dir_sync_ignored "$SCRIPT_DIR"/.venv

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
    if echo ":invalid.py:" | grep -q ":$py_file:"
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
  chdir_script
#   script="$(cat <<'EOF'
# import sys
# original_wokrking_dir_path = sys.argv[1]
# import os
# import subprocess
# scr_path = os.path.abspath(sys.argv[2])
# os.chdir(original_wokrking_dir_path)
# process = subprocess.Popen([sys.executable, scr_path] + sys.argv[3:])
# process.wait()
# sys.exit(process.returncode)
# EOF
# )"
#   script="$(echo "$script" | tr -d '\n')"
#   subcmd_rye run python -c "$script" "$ORIGINAL_DIR" "$@"
  subcmd_rye run python lib/run-py.py "$ORIGINAL_DIR" "$@"
)

subcmd_sync() { # Updates the Rye virtualenv.
  chdir_script
  subcmd_rye sync "$@"
}

subcmd_foo() {
  chdir_script
  # script="print('Hello, World!'); print('This is a Python script.')"
  script="$(cat <<'EOF'
print('Hello, World!')
print('This is a Python script.')
EOF
)"
  subcmd_rye run python -c "$script"
}
