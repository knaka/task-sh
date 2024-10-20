#!/bin/sh
set -o nounset -o errexit

test "${guard_5544dc4+set}" = set && return 0; guard_5544dc4=x

. task.sh
. task-rs-wasi.lib.sh

subcmd_run() {
  chdir_original
  subcmd_wasmtime target/wasm32-wasip1/debug/wasimain.wasm "$@"
  chdir_script
}

# shellcheck disable=SC2120
task_build() {
  subcmd_cargo component build "$@"
}

subcmd_install() {
  chdir_script
  task_build
  system_subcommands=":list:nop:help:"
  rs_bin_dir_path="$HOME"/wasi-bin
  mkdir -p "$rs_bin_dir_path"
  rm -f "$rs_bin_dir_path"/*
  for subcmd in $(subcmd_run list)
  do
    if echo "$system_subcommands" | grep -q ":$subcmd:"
    then
      continue
    fi
    if is_windows
    then
      rs_bin_file_path="$rs_bin_dir_path"/"$subcmd".cmd
      cat <<EOF > "$rs_bin_file_path"
@echo off
"$SCRIPT_DIR"\task.cmd run "$subcmd" %* || exit /b !ERRORLEVEL!
EOF
    else
      rs_bin_file_path="$rs_bin_dir_path"/"$subcmd"
      cat <<EOF > "$rs_bin_file_path"
#!/bin/sh
exec "$SCRIPT_DIR"/task run "$subcmd" "\$@"
EOF
      chmod +x "$rs_bin_file_path"
    fi
  done
}
