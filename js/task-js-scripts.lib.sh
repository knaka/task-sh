#!/bin/sh
set -o errexit -o nounset

test "${guard_00bf7e6+set}" = set && return 0; guard_00bf7e6=-

. task.sh

subcmd_install() ( # Install JS scripts.
  excluded_scrs=",invalid.js,"

  cd "$script_dir_path" || exit 1
  js_bin_dir_path="$HOME"/js-bin
  mkdir -p "$js_bin_dir_path"
  rm -f "$js_bin_dir_path"/*
  for js_file in *.js *.mjs *.cjs
  do
    if ! test -r "$js_file"
    then
      continue
    fi
    if echo "$excluded_scrs" | grep -q ",$js_file,"
    then
      continue
    fi
    # Ignore task files written in JS.
    case "$js_file" in
      task.cjs|task-*.cjs) continue ;;
    esac
    js_name="${js_file%.*}"
    if is_windows
    then
      js_bin_file_path="$js_bin_dir_path"/"$js_name".cmd
      cat <<EOF > "$js_bin_file_path"
@echo off
"$PWD"\task.cmd run "$PWD\\${js_file}" %* || exit /b !ERRORLEVEL!
EOF
    else 
      js_bin_file_path="$js_bin_dir_path"/"$js_name"
      cat <<EOF > "$js_bin_file_path"
#!/bin/sh
exec "$PWD"/task run "$PWD/${js_file}" "\$@"
EOF
      chmod +x "$js_bin_file_path"
    fi
  done
)

subcmd_run() { # Run JS script in the original working directory.
  original_wokrking_dir_path="$PWD"
  cd "$script_dir_path" || exit 1
  subcmd_volta run node -e 'require("cross-spawn").spawn(process.execPath, process.argv.slice(2), { stdio: "inherit", cwd: process.argv[1] }).on("close", (code) => process.exit(code));' "$original_wokrking_dir_path" "$@"
}
