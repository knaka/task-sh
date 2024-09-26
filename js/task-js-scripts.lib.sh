#!/bin/sh
set -o errexit -o nounset

excluded_scrs=",invalid.js,"

_install() {
  _is_windows=$1
  _js_bin_dir_path="$HOME"/js-bin
  mkdir -p "$_js_bin_dir_path"
  rm -f "$_js_bin_dir_path"/*
  for _js_file in *.js *.mjs *.cjs
  do
    if ! test -r "$_js_file"
    then
      continue
    fi
    if echo "$excluded_scrs" | grep -q ",$_js_file,"
    then
      continue
    fi
    case "$_js_file" in
      task.cjs|task-*.cjs) continue ;;
    esac
    _js_name="${_js_file%.*}"
    if $_is_windows
    then
      _js_bin_file_path="$_js_bin_dir_path"/"$_js_name".cmd
      cat <<EOF > "$_js_bin_file_path"
@echo off
"$PWD"\task.cmd run "$PWD\\${_js_file}" %* || exit /b !ERRORLEVEL!
EOF
    else 
      _js_bin_file_path="$_js_bin_dir_path"/"$_js_name"
      cat <<EOF > "$_js_bin_file_path"
#!/bin/sh
exec "$PWD"/task run "$PWD/${_js_file}" "\$@"
EOF
      chmod +x "$_js_bin_file_path"
    fi
  done
}

install_unix() {
  _install false
}

install_windows() {
  _install true
}

task_install() { # Install JS scripts.
  if is_windows
  then
    install_windows
  else
    install_unix
  fi
}

subcmd_run() { # Run JS script in the original working directory.
  original_wokrking_dir_path="$PWD"
  cd "$(dirname "$0")" || exit 1
  subcmd_volta run node -e 'require("cross-spawn").spawn(process.execPath, process.argv.slice(2), { stdio: "inherit", cwd: process.argv[1] }).on("close", (code) => process.exit(code));' "$original_wokrking_dir_path" "$@"
}
