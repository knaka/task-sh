#!/bin/sh
set -o nounset -o errexit

test "${guard_5544dc4+set}" = set && return 0; guard_5544dc4=x

. ./task.sh
. ./task-project.lib.sh

subcmd_install() {
  chdir_script
  subcmd_build
  system_subcommands=":list:nop:help:"
  rs_bin_dir_path="$HOME"/rs-bin
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
exec "$SCRIPT_DIR"/task.sh run "$subcmd" "\$@"
EOF
      chmod +x "$rs_bin_file_path"
    fi
  done
}
