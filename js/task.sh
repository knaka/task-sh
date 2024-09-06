#!/bin/sh
set -o nounset -o errexit

# Releases · volta-cli/volta https://github.com/volta-cli/volta/releases
cmd_base=volta
ver=2.0.1

# --------------------------------------------------------------------------

exe_ext=
arc_ext=".tar.gz"
case "$(uname -s)" in
  Linux)
    case "$(uname -m)" in
      x86_64) os_arch="linux" ;;
      arm64) os_arch="linux-arm" ;;
      *) exit 1;;
    esac
    ;;
  Darwin)
    os_arch="macos"
    ;;
  Windows_NT)
    exe_ext=".exe"
    arc_ext=".zip"
    case "$(uname -m)" in
      i386 | i486 | i586 | i686) os_arch="windows" ;;
      x86_64) os_arch="windows" ;;
      arm64) os_arch="windows-arm64" ;;
      *) exit 1;;
    esac
    ;;
  *)
    echo "Unsupported platform" >&2
    exit 1
    ;;
esac

bin_dir_path="$HOME"/.bin
cmd_path="$bin_dir_path/${cmd_base}@${ver}${exe_ext}"
if ! test -x "$cmd_path"
then
  url=https://github.com/volta-cli/volta/releases/download/v${ver}/volta-${ver}-${os_arch}${arc_ext}
  if test "$arc_ext" = ".tar.gz"
  then
    curl --location "$url" | tar -xz --directory="$bin_dir_path" $cmd_base
    mv "$bin_dir_path/$cmd_base" "$cmd_path"
  else
    temp_dir_path=$(mktemp -d)
    zip_path="$temp_dir_path"/temp.zip
    curl --location "$url" -o "$zip_path"
    (cd "$temp_dir_path"; unzip -q "$zip_path")
    mv "$temp_dir_path/$cmd_base$exe_ext" "$cmd_path"
    rm -fr "$temp_dir_path"
  fi
  chmod +x "$cmd_path"
fi

# --------------------------------------------------------------------------

if test "${1+SET}" != "SET"
then
  echo "Usage: $0 <subcmd> [args...]" >&2
  exit 1
fi

subcmd="$1"
shift

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

script_dir_path="$(dirname "$0")"
node_modules_dir_path="$script_dir_path"/node_modules
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
  (
    cd "$script_dir_path"
    "$cmd_path" run npm install
  )
fi

is_windows=$(test "$(uname -s)" = Windows_NT && echo true || echo false)
case "$subcmd" in
  nop)
    ;;
  install | link)
    if $is_windows
    then
      install_windows
    else
      install_unix
    fi
    ;;
  volta)
    exec "$cmd_path" "$@"
    ;;
  npm)
    exec "$cmd_path" run npm -- "$@"
    ;;
  run)
    original_wokrking_dir_path="$PWD"
    cd "$script_dir_path"
    node_cmd_path=$("$cmd_path" which node)
    echo exec "$node_cmd_path" lib/run-node.mjs "$original_wokrking_dir_path" "$@"
    exec "$node_cmd_path" lib/run-node.mjs "$original_wokrking_dir_path" "$@"
    ;;
  *)
    ;;
esac
