#!/bin/sh

subcmd_run() { # Run JS script.
  original_wokrking_dir_path="$PWD"
  cd "$(dirname "$0")" || exit 1
  exec "$(dirname "$0")"/volta-cmd run node lib/run-node.mjs "$original_wokrking_dir_path" "$@"
}

subcmd_volta() { # Run Volta.
  exec "$(dirname "$0")"/volta-cmd "$@"
}

subcmd_npm() { # Run npm.
  exec "$(dirname "$0")"/volta-cmd run npm -- "$@"
}

# --------------------------------------------------------------------------

node_modules_dir_path="$(dirname "$0")"/node_modules
if ! test -d "$node_modules_dir_path"
then
  mkdir -p "$node_modules_dir_path"
  if which attr > /dev/null 2>&1
  then
    attr -s 'com.dropbox.ignored' -V 1 "$node_modules_dir_path"
    attr -s 'com.apple.fileprovider.ignore#P' -V 1 "$node_modules_dir_path"
  elif which xattr > /dev/null 2>&1
  then
    xattr -w 'com.dropbox.ignored' 1 "$node_modules_dir_path"
    xattr -w 'com.apple.fileprovider.ignore#P' 1 "$node_modules_dir_path"
  elif which PowerShell > /dev/null 2>&1
  then
    PowerShell -Command "Set-Content -Path '$node_modules_dir_path' -Stream 'com.dropbox.ignored' -Value 1"
    PowerShell -Command "Set-Content -Path '$node_modules_dir_path' -Stream 'com.apple.fileprovider.ignore#P' -Value 1"
  fi
fi

# --------------------------------------------------------------------------

excluded_scrs=",invalid.py,"

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
    _js_name="${_js_file%.*}"
    if $_is_windows
    then
      _js_bin_file_path="$_js_bin_dir_path"/"$_js_name".cmd
      cat <<EOF > "$_js_bin_file_path"
@echo off
"$PWD"\task.cmd run "$PWD\\${_js_file}" %*
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

is_windows=$(test "$(uname -s)" = Windows_NT && echo true || echo false)

task_install() { # Install JS scripts.
    if $is_windows
  then
    install_windows
  else
    install_unix
  fi
}
