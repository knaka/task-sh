#!/bin/sh
set -o nounset -o errexit

volta_cmd() {
  # Releases · volta-cli/volta https://github.com/volta-cli/volta/releases
  cmd_base=volta
  ver=2.0.1

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
      # Mach-O universal binarries.
      os_arch="macos"
      ;;
    Windows_NT)
      exe_ext=".exe"
      arc_ext=".zip"
      case "$(uname -m)" in
        x86_64) os_arch="windows" ;;
        arm64) os_arch="windows-arm64" ;;
        *) exit 1;;
      esac
      ;;
    *)
      exit 1
      ;;
  esac
  bin_dir_path="$HOME"/.bin
  volta_dir_path="$bin_dir_path/${cmd_base}@${ver}"
  mkdir -p "$volta_dir_path"
  volta_cmd_path="$volta_dir_path/$cmd_base$exe_ext"
  if ! test -x "$volta_cmd_path"
  then
    url=https://github.com/volta-cli/volta/releases/download/v${ver}/volta-${ver}-${os_arch}${arc_ext}
    curl$exe_ext --fail --location "$url" -o - | (cd "$volta_dir_path"; tar$exe_ext -xf -)
    chmod +x "$volta_dir_path"/*
  fi
  PATH="$volta_dir_path:$PATH" "$cmd_base" "$@" || return $?
}

subcmd_volta() { # Run Volta.
  volta_cmd "$@"
}

subcmd_npm() { # Run npm.
  volta_cmd run npm -- "$@"
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
