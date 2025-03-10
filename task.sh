#!/usr/bin/env sh
# vim: set filetype=sh :
# shellcheck shell=sh
"${sourced_897a0c7-false}" && return 0; sourced_897a0c7=true

# --------------------------------------------------------------------------
# Constants.
# --------------------------------------------------------------------------

# shellcheck disable=SC2034
rc_delegate_task_not_found=10

# shellcheck disable=SC2034
rc_test_skipped=11

# --------------------------------------------------------------------------
# Temporary directory.
# --------------------------------------------------------------------------

TEMP_DIR="$(mktemp -d)"
# shellcheck disable=SC2064
trap "rm -fr '$TEMP_DIR'" EXIT

readonly stmts_file_base="$TEMP_DIR"/b6a5748

# Chain traps to not overwrite the previous trap.
# shellcheck disable=SC2064
chaintrap() {
  local stmts="$1"
  shift 
  local stmts_bak_file="$TEMP_DIR"/347803f
  local sigspec
  for sigspec in "$@"
  do
    sigspec=$(echo "$sigspec" | tr '[:lower:]' '[:upper:]')
    local stmts_file="$stmts_file_base"-"$sigspec"
    if test -f "$stmts_file"
    then
      cp "$stmts_file" "$stmts_bak_file"
    else
      touch "$stmts_bak_file"
    fi
    echo "{ $stmts; };" >"$stmts_file"
    cat "$stmts_bak_file" >>"$stmts_file"
    # shellcheck disable=SC2154
    trap "rc=\$?; . '$stmts_file'; rm -fr '$TEMP_DIR'; exit \$rc" "$sigspec"
  done
}

# Call the finalization function before `exec`.
finalize() {
  local stmts_file="$stmts_file_base"-EXIT
  # shellcheck disable=SC1090
  test -f "$stmts_file" && . "$stmts_file"
  rm -fr "$TEMP_DIR"
}

# --------------------------------------------------------------------------
# Environment variables. If not set by the caller, set later in `main`
# --------------------------------------------------------------------------

# Path to the shell executable.
: "${SH:=}"

# Basename of the shell executable.
: "${SHBASE:=}"

# Directory in which the script has been invoked.
: "${WORKING_DIR:=}"

# Directory in which the task files are located.
: "${TASKS_DIR:=}"

# The root directory of the project.
: "${PROJECT_DIR:=}"

# The path to the file which was called.
: "${ARG0:=}"

# Basename of the file which was called.
: "${ARG0BASE:=}"

# Verbosity flag.
: "${VERBOSE:=false}"

verbose() {
  "$VERBOSE"
}

# Cache directory.
: "${CACHE_DIR:="$HOME"/.cache}"

cache_dir_path() {
  local global_cache_dir_path="$HOME/.cache"
  # if is_windows
  # then
  #   global_cache_dir_path="$LOCALAPPDATA"
  # elif is_macos
  # then
  #   global_cache_dir_path="$HOME/Library/Caches"
  # fi
  mkdir -p "$global_cache_dir_path"/task_sh
  echo "$global_cache_dir_path"/task_sh
}

# --------------------------------------------------------------------------
# Platform detection.
# --------------------------------------------------------------------------

is_linux() {
  test -d /proc -o -d /sys
}

is_macos() {
  test -r /System/Library/CoreServices/SystemVersion.plist
}

is_windows() {
  test -d "c:/" -a ! -d /proc
}

is_debian() {
  test -f /etc/debian_version
}

is_bsd() {
  # stat -f "%z" . >/dev/null 2>&1
  is_macos || test -r /etc/rc.subr
}

is_alpine() {
  test -f /etc/alpine-release
}

# --------------------------------------------------------------------------
# Binary - text encoding/decoding.
# --------------------------------------------------------------------------

oct_dump() {
  if test $# -eq 0
  then
    cat
  else
    printf "%s" "$*"
  fi | od -A n -t o1 -v | xargs printf "%s "
}

oct_restore() {
  if test $# -eq 0
  then
    cat
  else
    printf "%s" "$*"
  fi | xargs printf '\\\\0%s\n' | xargs printf '%b'
}

oct_encode() {
  if test $# -eq 0
  then
    cat
  else
    printf "%s" "$*"
  fi | od -A n -t o1 -v | xargs printf "%s"
}

oct_decode() {
  if test $# -eq 0
  then
    cat
  else
    printf "%s" "$*"
  fi | sed 's/.../& /g' | xargs printf '\\\\0%s\n' | xargs printf '%b'
}

hex_dump() {
  od -A n -t x1 -v | xargs printf "%s "
}

hex_restore() {
  set -- awk
  if command -v mawk >/dev/null 2>&1
  then
    set -- mawk
  elif command -v gawk >/dev/null 2>&1
  then
    set -- gawk --non-decimal-data
  fi
  # shellcheck disable=SC2016
  xargs printf "%s\n" | "$@" '{ printf("%c", int("0x" $1)) }'
}

# --------------------------------------------------------------------------
# IFS manipulation.
# --------------------------------------------------------------------------

# shellcheck disable=SC2034
readonly unit_sep=""

# Unit separator.
# shellcheck disable=SC2034
readonly us=""

# Information separator one.
# shellcheck disable=SC2034
readonly is1=""

# Information separator two.
# shellcheck disable=SC2034
readonly is2=""

# Information separator three.
# shellcheck disable=SC2034
readonly is3=""

# Information separator four.
# shellcheck disable=SC2034
readonly is4=""

set_ifs_newline() {
  IFS="$(printf '\n\r')"
}

# shellcheck disable=SC2034
readonly newline="
"

# To split path.
set_ifs_slashes() {
  printf "/\\"
}

set_ifs_default() {
  printf ' \t\n\r'
}

set_ifs_blank() {
  printf ' \t'
}

csv_ifss_6b672ac=

# Push IFS to the stack.
push_ifs() {
  if test "${IFS+set}" = set
  then
    csv_ifss_6b672ac="$(printf "%s" "$IFS" | oct_dump),$csv_ifss_6b672ac"
  else
    csv_ifss_6b672ac=",$csv_ifss_6b672ac"
  fi
  if test $# -gt 0
  then
    IFS="$1"
  fi
}

# Pop IFS from the stack.
pop_ifs() {
  if test -z "$csv_ifss_6b672ac"
  then
    return 1
  fi
  local v
  v="${csv_ifss_6b672ac%%,*}"
  csv_ifss_6b672ac="${csv_ifss_6b672ac#*,}"
  if test -n "$v"
  then
    IFS="$(printf "%s" "$v" | oct_restore)"
  else
    unset IFS
  fi
}

# --------------------------------------------------------------------------
# Directory stack.
# --------------------------------------------------------------------------

psv_dirs_4c15d80=

# `pushd` alternative.
push_dir() {
  local pwd="$PWD"
  if ! cd "$1"
  then
    echo "No such directory: $1" >&2
    return 1
  fi
  psv_dirs_4c15d80="$pwd|$psv_dirs_4c15d80"
}

# `popd` alternative.
pop_dir() {
  if test -z "$psv_dirs_4c15d80"
  then
    echo "Directory stack is empty." >&2
    return 1
  fi
  local dir="${psv_dirs_4c15d80%%|*}"
  psv_dirs_4c15d80="${psv_dirs_4c15d80#*|}"
  cd "$dir" || return 1
}

# --------------------------------------------------------------------------
# Shell flags. Not nested.
# --------------------------------------------------------------------------

shell_flags_c225b8f=

# Backup the current shell flags.
backup_shell_flags() {
  if test -n "$shell_flags_c225b8f"
  then
    # Fails to save the state if it was already saved. Does not nest.
    return 1
  fi
  shell_flags_c225b8f="$(set +o)"
}

# Restore the shell flags saved by `backup_shell_flags`.
restore_shell_flags() {
  if test -z "$shell_flags_c225b8f"
  then
    # Fails to restore the state if it was not saved.
    return 1
  fi
  eval "$shell_flags_c225b8f"
  shell_flags_c225b8f=
}

# --------------------------------------------------------------------------
# Misc.
# --------------------------------------------------------------------------s

# shuf(1) for MacOS environment.
if ! command -v shuf >/dev/null 2>&1
then
  alias shuf='sort -R'
fi

# Executable file extension.
exe_ext() {
  if is_windows
  then
    echo ".exe"
  fi
}

if is_macos
then
  alias sha1sum='shasum -a 1'
fi

# Memoize the (mainly external) command output.
memoize() {
  local cache_file_path="$TEMP_DIR"/cache-"$(echo "$@" | sha1sum | cut -d' ' -f1)"
  if ! test -r "$cache_file_path"
  then
    "$@" >"$cache_file_path"
  fi
  cat "$cache_file_path"
}

# Memoize the output of a series of commands. If you would like to nest, use subprocess function or `memoize` function instead.
#
# Usage:
#   foo() {
#     begin_memoize 8701441 "$@" || return 0
#
#     echo hello
#     sleep 3 # Takes long time.
#     echo world
#
#     end_memoize
#   }

# Current cache file path for memoization.
cache_file_path_cb3727b=

begin_memoize() {
  cache_file_path_cb3727b="$TEMP_DIR"/cache-"$(echo "$@" | sha1sum | cut -d' ' -f1)"
  if test -r "$cache_file_path_cb3727b"
  then
    cat "$cache_file_path_cb3727b"
    return 1
  fi
  exec 9>&1
  exec >"$cache_file_path_cb3727b"
}

end_memoize() {
  exec 1>&9
  exec 9>&-
  cat "$cache_file_path_cb3727b"
}

# The path to the shell executable which is running the script.
shell_path() {
  begin_memoize d57754a "$@" || return 0

  if test "${BASH+set}" = set
  then
    echo "$BASH"
  elif is_windows && test "${SHELL+set}" = set && test "$SHELL" = "/bin/sh" && "$SHELL" --help 2>&1 | grep -q "BusyBox"
  then
    echo "$SHELL"
  else
    local path=
    if test -e /proc/$$/exe
    then
      path="$(realpath /proc/$$/exe)" || return 1
    else
      path="$(realpath "$(ps -p $$ -o comm=)")" || return 1
    fi
    echo "$path"
  fi

  end_memoize
}

# The implementation name of the shell which is running the script. Not "sh" but "bash", "ash", "dash", etc.
shell_name() {
  begin_memoize 09e4c0d "$@" || return 0

  if test "${BASH+set}" = set
  then
    echo "bash"
  elif is_windows && test "${SHELL+set}" = set && test "$SHELL" = "/bin/sh" && "$SHELL" --help 2>&1 | grep -q "BusyBox"
  then
    echo "ash"
  else
    local path=
    if test -e /proc/$$/exe
    then
      path="$(realpath /proc/$$/exe)" || return 1
    else
      path="$(realpath "$(ps -p $$ -o comm=)")" || return 1
    fi
    case "${path##*/}" in
      (bash) echo "bash";;
      (ash) echo "ash";;
      (dash) echo "dash";;
      (sh|busybox)
        if "$path" --help 2>&1 | grep -q "BusyBox"
        then
          echo "ash"
        else
          echo "Cannot detect the shell: $path" >&2
          return 1
        fi
        ;;
      (*)
        echo "Unknown shell: $path" >&2
        return 1
        ;;
    esac
  fi

  end_memoize
}

is_dash() {
  test "$(shell_name)" = "dash"
}

is_ash() {
  test "$(shell_name)" = "ash"
}

is_bash() {
  test "$(shell_name)" = "bash"
}

# Check if the file(s)/directory(s) is/are newer than the destination.
newer() {
  local found_than=false
  local dest=
  local arg
  for arg in "$@"
  do
    shift
    if test "$arg" = "--than"
    then
      found_than=true
    elif $found_than
    then
      dest="$arg"
    else
      set -- "$@" "$arg"
    fi
  done
  if test -z "$dest"
  then
    echo "No --than option" >&2
    exit 1
  fi
  if test "$#" -eq 0
  then
    echo "No source files" >&2
    exit 1
  fi
  # If the destination does not exist, it is considered newer than the destination.
  if ! test -e "$dest"
  then
    echo "Destination does not exist: $dest" >&2
    return 0
  fi
  # If the destination is a directory, the newest file in the directory is used.
  if test -d "$dest"
  then
    if is_bsd
    then
      dest="$(find "$dest" -type f -exec stat -l -t "%F %T" {} \+ | cut -d' ' -f6- | sort -n | tail -1 | cut -d' ' -f3)"
    else
      dest="$(find "$dest" -type f -exec stat -Lc '%Y %n' {} \+ | sort -n | tail -1 | cut -d' ' -f2)"
    fi
  fi
  if test -z "$dest"
  then
    echo "No destination file" >&2
    return 0
  fi
  test -n "$(find "$@" -newer "$dest" 2>/dev/null)"
}

# Kill child processes for each shell/platform.
kill_child_processes() {
  if is_windows
  then
    # Windows BusyBox ash
    # If the process is killed with pid, ash does not kill `exec`ed subprocesses.
    local jids
    jids="$TEMP_DIR"/jids
    # ash provides “jobs pipe”.
    jobs | sed -E -e 's/^[^0-9]*([0-9]+).*Running *(.*)/\1/' >"$jids"
    while read -r jid
    do
      kill "%$jid" || :
      wait "%$jid" || :
      echo Killed "%$jid" >&2
    done <"$jids"
  elif is_macos
  then
    pkill -P $$ || :
  elif is_linux
  then
    if is_bash
    then
      local jids
      jids="$TEMP_DIR"/jids
      # Bash provides “jobs pipe”.
      jobs | sed -E -e 's/^[^0-9]*([0-9]+).*Running *(.*)/\1/' >"$jids"
      while read -r jid
      do
        kill "%$jid" || :
        wait "%$jid" || :
        echo Killed "%$jid" >&2
      done <"$jids"
    else
      pkill -P $$ || :
    fi
  else
    echo "kill_child_processes: Unsupported platform or shell." >&2
    exit 1
  fi
}

# Invoke command with proper executable extension, with the specified invocation mode.
#
#   --invocation-mode=exec: Replace the process with the command.
#   --invocation-mode=exec-sub: Replace the process with the command, without calling cleanups.
#   --invocation-mode=background: Run the command in the background.
#   --invocation-mode=standard: Run the command in the current process.
invoke() {
  local invocation_mode=standard
  local arg
  for arg in "$@"
  do
    case "$arg" in
      (--invocation-mode=*) invocation_mode=${arg#--invocation-mode=};;
      (*) set -- "$@" "$arg";;
    esac
    shift
  done
  if test $# -eq 0
  then
    echo "No command specified" >&2
    exit 1
  fi
  case "$1" in
    (*/*)
      if is_windows
      then
        local cmd="$1"
        local ext
        for ext in .exe .cmd .bat
        do
          if test -x "$cmd$ext"
          then
            shift
            set -- "$cmd$ext" "$@"
            break
          fi
        done
      fi
      if ! test -x "$1"
      then
        echo "Command not found: $1" >&2
        exit 1
      fi
      ;;
    (*)
      if is_windows
      then
        local cmd="$1"
        local ext
        for ext in .exe .cmd .bat
        do
          if command -v "$1$ext" >/dev/null 2>&1
          then
            shift
            set -- "$cmd$ext" "$@"
            break
          fi
        done
      fi
      if ! command -v "$1" >/dev/null 2>&1
      then
        echo "Command not found: $1" >&2
        exit 1
      fi
      ;;
  esac
  case "$invocation_mode" in
    (exec)
      finalize
      exec "$@"
      ;;
    (exec-sub) exec "$@";;
    (background) "$@" &;;
    (standard)
      "$@"
      ;;
    (*)
      echo "Unknown invocation mode: $invocation_mode" >&2
      exit 1
      ;;
  esac
}

# Open the URL in the browser.
browse() {
  if is_linux
  then
    xdg-open "$1"
  elif is_macos
  then
    open "$1"
  elif is_windows
  then
    PowerShell -Command "Start-Process '$1'"
  else
    echo "Unsupported OS: $(uname -s)" >&2
    exit 1
  fi
}

# Ensure the command is installed.
install_pkg_cmd() {
  local apk_id=
  local deb_id=
  local cmd=
  local winget_id=
  local win_cmd_path=
  local scoop_id=
  local brew_id=
  local mac_cmd_path=
  OPTIND=1; while getopts _-: OPT
  do
    if test "$OPT" = "-"
    then
      OPT="${OPTARG%%=*}"
      # shellcheck disable=SC2030
      OPTARG="${OPTARG#"$OPT"}"
      OPTARG="${OPTARG#=}"
    fi
    case "$OPT" in
      (apk-id) apk_id=$OPTARG;;
      (brew-id) brew_id=$OPTARG;;
      (mac-cmd-path) mac_cmd_path=$OPTARG;;
      (cmd) cmd=$OPTARG;;
      (deb-id) deb_id=$OPTARG;;
      (winget-id) winget_id=$OPTARG;;
      (win-cmd-path) win_cmd_path=$OPTARG;;
      (scoop-id) scoop_id=$OPTARG;;
      (\?) exit 1;;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  # If found, do not install.
  if command -v "$cmd" >/dev/null 2>&1
  then
    :
  # Otherwise, install.
  elif is_windows
  then
    if test -n "$win_cmd_path"
    then
      cmd="$win_cmd_path"
    fi
    if command -v "$cmd" >/dev/null 2>&1
    then
      :
    elif test -n "$scoop_id"
    then
      if ! command -v scoop > /dev/null 2>&1
      then
        powershell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser; Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression" 1>&2
      fi
      scoop install "$scoop_id" 1>&2
    elif test -n "$winget_id"
    then
      winget install --accept-package-agreements --accept-source-agreements --exact --id "$winget_id" 2>&1
    else
      echo "No package ID for Windows specified." >&2
      exit 1
    fi
  elif is_macos
  then
    if test -n "$mac_cmd_path"
    then
      cmd="$mac_cmd_path"
    fi
    if command -v "$cmd" >/dev/null 2>&1
    then
      :
    elif test -n "$brew_id"
    then
      brew install "$brew_id" 1>&2
    else
      echo "No package ID for macOS specified." >&2
      exit 1
    fi
  elif is_linux
  then
    local sudo=
    if command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null
    then
      sudo=sudo
    fi
    if command -v apt-get >/dev/null 2>&1
    then
      if ! test -d /var/lib/apt/lists || is_dir_empty /var/lib/apt/lists
      then
        $sudo apt-get update 1>&2
      fi
      $sudo apt-get install -y "$deb_id" 1>&2
    elif command -v apk >/dev/null 2>&1
    then
      apk add "$apk_id" 1>&2
    fi
  else
    echo "Unsupported OS: $(uname -s)" >&2
    exit 1
  fi

  if command -v "$cmd" >/dev/null 2>&1
  then
    command -v "$cmd"
  else
    echo "Command not installed: $cmd" >&2
    return 1
  fi
}

# Run a command after ensuring it is installed.
run_pkg_cmd() {
  local cmd_path=
  cmd_path="$(install_pkg_cmd "$@")"
  while test $# -gt 0
  do
    if test "$1" = "--"
    then
      shift
      break
    fi
    shift
  done
  invoke "$cmd_path" "$@"
}

subcmd_curl() { # Run curl(1). This will be deprecated. Use `fetch` instead.
  run_pkg_cmd \
    --cmd=curl \
    --deb-id=curl \
    --apk-id=curl \
    -- "$@"
}

subcmd_apt_download() {
  ! is_debian && return 1
  local apt_conf_path="$TEMP_DIR"/apt.conf
  printf "%s\n" \
    'Acquire::https::Verify-Peer "false";' \
    'Acquire::https::Verify-Host "false";' \
    >"$apt_conf_path"
  /usr/lib/apt/apt-helper -c "$apt_conf_path" download-file "$1" "$2" 1>&2
}

subcmd_fetch() { # Fetch data from the URL to the standard output.
  if test $# -eq 0
  then
    echo "No URL specified." >&2
    exit 1
  fi
  if command -v wget >/dev/null 2>&1
  then
    # wget(1) follows redirects by default.
    invoke wget --quiet --output-document=- "$@"
    return $?
  fi
  local curl_path=
  if command -v curl >/dev/null 2>&1
  then
    curl_path="$(command -v curl)"
  elif test -x "$(cache_dir_path)"/curl
  then
    curl_path="$(cache_dir_path)"/curl
  elif is_linux && test -x /usr/lib/apt/apt-helper
  then
    # Release v8.11.0 · moparisthebest/static-curl https://github.com/moparisthebest/static-curl/releases/tag/v8.11.0
    local curl_version=v8.11.0
    # Copied from `sha256sum.txt`
    local curl_sha256sums='
d18aa1f4e03b50b649491ca2c401cd8c5e89e72be91ff758952ad2ab5a83135d  ./curl-amd64
1a4747fd88b31b93bf48bcace9d1e3ebf348afbbf8c0a6f4e1751795ea6ff39b  ./curl-i386
1b050abd1669f9a2ac29b34eb022cdeafb271dce5a4fb57d8ef8fadff6d7be1f  ./curl-aarch64
779a1bd9f486fd5ff1da25d5e5bb99c58bc79ded22344f2b7ff366cf645a6630  ./curl-armv7
b92dc31e0d614e04230591377837f44ff2c98430c821d93a5aaa0fae30c0fd1c  ./curl-armhf
50be538158f06fa71a4751d9f3f06932dc90337d43768b4963af51e84ebb65ac  ./curl-ppc64le
'
    curl_path="$(cache_dir_path)"/curl
    local arch=
    case "$(uname -m)" in
      (x86_64) arch=amd64;;
      (aarch64) arch=aarch64;;
      (*) echo "Unsupported architecture: $(uname -m)" >&2; return 1;;
    esac
    mkdir -p "$(dirname "$curl_path")"
    local curl_url="https://github.com/moparisthebest/static-curl/releases/download/$curl_version/curl-$arch"
    subcmd_apt_download "$curl_url" "$curl_path"
    if ! echo "$(echo "$curl_sha256sums" | grep "$(basename "$curl_url")" | cut -d' ' -f1)" "$curl_path" | sha256sum --check --status
    then
      echo "curl checksum mismatch." >&2
      return 1
    fi
    chmod +x "$curl_path"
  else
    echo "Neither wget nor curl is available." >&2
    return 1
  fi
  if ! test -d /etc/ssl
  then
    # curl - Extract CA Certs from Mozilla https://curl.se/docs/caextract.html
    local cacert_url="https://curl.se/ca/cacert-2024-12-31.pem"
    local cacert_sha256sum="a3f328c21e39ddd1f2be1cea43ac0dec819eaa20a90425d7da901a11531b3aa5"
    invoke "$curl_path" --insecure --location --output "$(cache_dir_path)"/cacert.pem "$cacert_url"
    if ! echo "$cacert_sha256sum" "$(cache_dir_path)"/cacert.pem | sha256sum --check --status 1>&2
    then
      echo "cacert.pem checksum mismatch." >&2
      return 1
    fi
    set -- --cacert "$(cache_dir_path)"/cacert.pem "$@"
  fi
  invoke "$curl_path" --location --output - "$@"
}

# Load environment variables from the specified file.
load_env_file() {
  if ! test -r "$1"
  then
    return 0
  fi
  local line
  local key
  local value
  while read -r line
  do
    key="${line%%=*}"
    if test -z "$key" || test "$key" = "$line"
    then
      continue
    fi
    value="$(eval "echo \"\${$key:=}\"")"
    # Not to overwrite the existing, previously set value.
    if test -n "$value"
    then
      continue
    fi
    eval "$line"
  done <"$1"
}

# Load environment variables.
load_env() {
  # Load the files in the order of priority.
  if test "${APP_ENV+set}" = set
  then
    load_env_file "$PROJECT_DIR"/.env."$APP_ENV".session
    load_env_file "$PROJECT_DIR"/.env."$APP_ENV".local
  fi
  if test "${APP_ENV+set}" != set || test "${APP_ENV}" != "test"
  then
    load_env_file "$PROJECT_DIR"/.env.session
    load_env_file "$PROJECT_DIR"/.env.local
  fi
  if test "${APP_ENV+set}" = set
  then
    load_env_file "$PROJECT_DIR"/.env."$APP_ENV"
  fi
  # shellcheck disable=SC1091
  load_env_file "$PROJECT_DIR"/.env
}

# Get a key from the user without echoing.
get_key() {
  if is_linux || is_macos
  then
    local saved_stty
    saved_stty="$(stty -g)"
    stty -icanon -echo
    dd bs=1 count=1 2>/dev/null
    stty "$saved_stty"
    return
  fi
  local key
  # Bash POSIX Shell and BusyBox Ash provides `-s` (silent mode) option.
  if test is_ash || is_bash
  then
    # shellcheck disable=SC3045
    read -rsn1 key
    return
  else
    read -r key
  fi
  echo "$key"
}

# Show a message and get an input from the user.
prompt() {
  local message="${1:-Text}"
  local default="${2:-}"
  printf "%s: (%s) " "$message" "$default" >&2
  local response
  read -r response
  if test -z "$response"
  then
    response="$default"
  fi
  printf "%s" "$response"
}

prompt_confirm() {
  local message="${1:-Text}"
  local default="${2:-n}"
  local selection
  case "$default" in
    (y|Y|yes|Yes|YES)
      default=y
      selection="Y/n"
      ;;
    (n|N|no|No|NO)
      default=n
      selection="y/N"
      ;;
    (*)
      echo "Invalid default value: $default" >&2
      return 1
  esac
  printf "%s [%s]: " "$message" "$selection" >&2
  local response
  response="$(get_key)"
  if test -z "$response"
  then
    response="$default"
  fi
  echo "$response" >&2
  case "$response" in
    (y|Y)
      return 0
      ;;
    (n|N)
      return 1
      ;;
  esac
}

# Create a file from the standard input if it does not exist.
ensure_file() {
  local file_path="$1"
  if test -f "$file_path"
  then
    echo "File $file_path already exists. Skipping the creation." >&2
    return 0
  fi
  echo "Creating the $file_path file." >&2
  mkdir -p "$(dirname "$file_path")"
  cat >"$file_path"
}

# Guard against multiple calls.
first_call() {
  if eval "test \"\${called_$1-}\" = true"
  then
    return 1
  fi
  eval "called_$1=true"
}

underline() {
  printf '\033[4m%s\033[0m' "$1"
}

bold() {
  printf '\033[1m%s\033[0m' "$1"
}

enclose_with_brackets() {
  printf '[%s]' "$1"
}

# Emphasize text.
emph() {
  if test -z "$1"
  then
    return
  fi
  if is_windows
  then
    enclose_with_brackets "$(bold "$(underline "$1")")"
  else
    bold "$(underline "$1")"
  fi
}

# Sort version strings.
# Version strings which are composed of three parts are sorted considering the third part as a patch version.
# Long option `--version-sort` is specific to BSD sort(1).
# shellcheck disable=SC2120
sort_version() {
  sed -E -e '/-/! { s/^([^.]+(\.[^.]+){2})$/\1_/; }' -e 's/-patch/_patch/' | sort -V "$@" | sed -e 's/_$//' -e 's/_patch/-patch/'
}

# Check if the version is greater than the specified version.
version_gt() {
  test "$(printf '%s\n' "$@" | sort_version | head -n 1)" != "$1"
}

version_ge() {
  test "$(printf '%s\n' "$@" | sort_version -r | head -n 1)" = "$1"
}

# Left/Right-Word-Boundary regex incompatible with BSD sed // re_format(7) https://man.freebsd.org/cgi/man.cgi?query=re_format&sektion=7
lwb='\<'
rwb='\>'
# shellcheck disable=SC2034
if is_bsd
then
  lwb='[[:<:]]'
  rwb='[[:>:]]'
fi

# Print a menu item with emphasis if a character is prefixed with "&".
menu_item() {
  echo "$1" | sed -E \
    -e 's/&&/@ampersand_ff37f3a@/g' \
    -e "s/^([^&]*)(&([^& ]))?(.*)$/\1${is1}\3${is1}\4/" \
  | (
    IFS="$is1" read -r pre char_to_emph post
    if test -n "$char_to_emph"
    then
      printf -- "%s%s%s" "$pre" "$(emph "$char_to_emph")" "$post"
    else
      printf -- "%s" "$pre"
    fi
  ) | sed -E -e 's/@ampersand_ff37f3a@/\&/g'
  echo
}

# Print a menu
menu() {
  local arg
  for arg in "$@"
  do
    printf -- "- "
    menu_item "$arg"
  done
}

# Get the space-separated n-th (1-based) field.
field() {
  # shellcheck disable=SC2046
  printf "%s\n" $(cat) | head -n "$1" | tail -n 1
}

# tac(1) for MacOS environment.
if ! command -v tac >/dev/null 2>&1
then
  tac() {
    tail -r
  }
fi

# Encode positional parameters into a string which can be passed to `eval` to restore the positional parameters.
#
# Example:
#   local eval_args="$(make_eval_args "$@")"
#   set --
#   eval "set -- $eval_args"
make_eval_args() {
  local arg
  local first
  # Quotation character inside parameter expansion confuses static analysis tools.
  local quote="'"
  for arg in "$@"
  do
    printf "'"
    until test "$arg" = "${arg#*"$quote"}"
    do
      first="${arg%%"$quote"*}"
      arg="${arg#*"$quote"}"
      printf "%s'\"'\"'" "$first"
    done
    printf "%s' " "$arg"
  done
}

# Check if the directory is empty.
is_dir_empty() {
  if ! test -d "$1"
  then
    return 1
  fi
  if ! test -e "$1"/* 2>/dev/null
  then
    return 0
  fi
  return 1
}

# --------------------------------------------------------------------------
# Main.
# --------------------------------------------------------------------------

psv_task_file_paths_4a5f3ab=

task_subcmds() ( # List subcommands.
  lines="$(
    (
      IFS="|"
      # shellcheck disable=SC2086
      sed -E -n -e 's/^subcmd_([[:alnum:]_]+)\(\) *[{(] *(# *(.*))?/\1 \3/p' $psv_task_file_paths_4a5f3ab
    ) | while read -r name desc
    do
      echo "$(echo "$name" | sed -E -e 's/__/:/g')" "$desc"
    done
    if type delegate_tasks >/dev/null 2>&1 && delegate_tasks subcmds >/dev/null 2>&1
    then
      delegate_tasks subcmds
    fi
  )"
  max_name_len="$(
    echo "$lines" \
    | while read -r name _
    do
      echo "${#name}"
    done \
    | sort -nr \
    | head -1
  )"
  echo "$lines" | while read -r name desc
  do
    printf "%-${max_name_len}s  %s\n" "$name" "$desc"
  done | sort
)

task_tasks() ( # List tasks.
  lines="$(
    (
      IFS="|"
      # shellcheck disable=SC2086
      sed -E -n -e 's/^task_([[:alnum:]_]+)\(\) *[{(] *(# *(.*))?/\1 \3/p' $psv_task_file_paths_4a5f3ab
    ) | while read -r name desc
    do
      echo "$(echo "$name" | sed -E -e 's/__/:/g')" "$desc"
    done
    if type delegate_tasks >/dev/null 2>&1 && delegate_tasks tasks >/dev/null 2>&1
    then
      delegate_tasks tasks
    fi
  )"
  max_name_len="$(
    echo "$lines" \
    | while read -r name _
    do
      echo "${#name}"
    done \
    | sort -nr \
    | head -1
  )"
  echo "$lines" | while read -r name desc
  do
    printf "%-${max_name_len}s  %s\n" "$name" "$desc"
  done | sort
)

usage() ( # Show help message.
  cat <<EOF
Usage:
  $ARG0BASE [options] <subcommand> [args...]
  $ARG0BASE [options] <task[arg1,arg2,...]> [tasks...]

Options:
  -d, --directory=<dir>  Change directory before running tasks.
  -h, --help             Display this help and exit.
  -v, --verbose          Verbose mode.

Subcommands:
$(task_subcmds | while IFS= read -r line; do echo "  $line"; done)

Tasks:
$(task_tasks | while IFS= read -r line; do echo "  $line"; done)
EOF
)

subcmd_exec() { # Execute a command in task.sh context.
  backup_shell_flags
  set +o errexit
  "$@"
  echo "Exit status: $?" >&2
  restore_shell_flags
}

run_pre_task() {
  if type pre_"$1" > /dev/null 2>&1
  then
    echo "Running pre-task for $1" >&2
    pre_"$1"
  fi
}

run_post_task() {
  if type post_"$1" > /dev/null 2>&1
  then
    echo "Running post-task for $1" >&2
    post_"$1"
  fi
}

main() {
  set -o nounset -o errexit

  chaintrap kill_child_processes EXIT TERM INT

  # If launched by `task`, $SH is set. Otherwise, determine the shell.
  if test -z "$SH"
  then
    SH="$(shell_path)"
    SHBASE="${SH##*/}"
    while true
    do
      if is_windows
      then
        if test "$SHBASE" = "sh"
        then
          break
        fi
      elif is_macos
      then
        if test "$SHBASE" = "dash"
        then
          break
        fi
        finalize
        exec /bin/dash "$0" "$@"
      elif is_linux
      then
        case "$SHBASE" in
          (ash|dash|bash)
            break
            ;;
        esac
      fi
      echo "Unsupported environment: $(uname -s)", "$SH" >&2
      exit 1
    done
    export SH
    export SHBASE
  fi

  if test -z "$WORKING_DIR"
  then
    WORKING_DIR="$(realpath "$PWD")"
    export WORKING_DIR
  fi

  if test -z "$TASKS_DIR"
  then
    TASKS_DIR="$(realpath "$(dirname "$0")")"
    export TASKS_DIR
  fi

  if test -z "${PROJECT_DIR}"
  then
    if test "${ARG0+set}" = set
    then
      PROJECT_DIR="$(realpath "$(dirname "$ARG0")")"
    else
      local dir="$PWD"
      local parent_dir
      while true
      do
        if test -d "$dir"/tasks || test -f "$dir/task.sh"
        then
          PROJECT_DIR="$dir"
          break
        fi
        parent_dir="$(realpath "$dir"/..)"
        if test "$dir" = "$parent_dir"
        then
          echo "Project directory not found." >&2
          exit 1
        fi
        dir="$parent_dir"
      done
    fi
    export PROJECT_DIR
  fi

  # Set the environment variables according to the script name.
  if test "${ARG0BASE+set}" = "set"
  then
    case "$ARG0BASE" in
      (task-*)
        env="${ARG0BASE#task-}"
        case "$env" in
          (dev|development)
            APP_ENV=development
            APP_SENV=dev
            ;;
          (prd|production)
            APP_ENV=production
            APP_SENV=prd
            ;;
          (*) echo "Unknown environment: $env" >&2; exit 1;;
        esac
        export APP_ENV APP_SENV
        ;;
      (*)
        ;;
    esac
  else
    # shellcheck disable=SC2034
    ARG0="$0"
    ARG0BASE="$(basename "$0")"
  fi

  # Load all the task files in the tasks directory and the project directory. All the task files are sourced in the TASKS directory context.
  psv_task_file_paths_4a5f3ab="$(realpath "$0")|"
  load_tasks_in_dir() {
    push_dir "$TASKS_DIR"
    for task_file_path in "$1"/task-*.sh
    do
      if ! test -r "$task_file_path"
      then
        continue
      fi
      case "$(basename "$task_file_path")" in
        (task-dev.sh|task-prd.sh)
          continue
          ;;
      esac
      psv_task_file_paths_4a5f3ab="$psv_task_file_paths_4a5f3ab$task_file_path|"
      # echo Loading "$task_file_path" >&2
      # shellcheck disable=SC1090
      . "$task_file_path"
    done
    pop_dir
  }
  load_tasks_in_dir "$PROJECT_DIR"
  test "$TASKS_DIR" != "$PROJECT_DIR" && load_tasks_in_dir "$TASKS_DIR"

  # Parse the command line arguments.
  shows_help=false
  skip_missing=false
  ignore_missing=false
  OPTIND=1; while getopts hvsi-: OPT
  do
    if test "$OPT" = "-"
    then
      # Extract long option name.
      # shellcheck disable=SC2031
      OPT="${OPTARG%%=*}"
      # Extract long option argument.
      # shellcheck disable=SC2031
      OPTARG="${OPTARG#"$OPT"}"
      OPTARG="${OPTARG#=}"
    fi
    case "$OPT" in
      (h|help) shows_help=true;;
      (s|skip-missing) skip_missing=true;;
      (i|ignore-missing) ignore_missing=true;;
      (v|verbose) VERBOSE=true;;
      (\?) usage; exit 1;;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  # Show help message and exit.
  if $shows_help || test "${1+set}" != "set"
  then
    usage
    exit 0
  fi

  # Execute the subcommand and exit.
  subcmd="$(echo "$1" | sed -r -e 's/:/__/g')"
  if type subcmd_"$subcmd" > /dev/null 2>&1
  then
    shift
    if alias subcmd_"$subcmd" > /dev/null 2>&1
    then
      # run_pre_task subcmd_"$subcmd"
      # shellcheck disable=SC2294
      eval subcmd_"$subcmd" "$@"
      # run_post_task subcmd_"$subcmd"
      exit $?
    fi
    # run_pre_task subcmd_"$subcmd"
    subcmd_"$subcmd" "$@"
    exit $?
  fi
  case "$subcmd" in
    (subcmd_*)
      if type "$subcmd" > /dev/null 2>&1
      then
        # run_pre_task "$subcmd"
        shift
        "$subcmd" "$@"
        # run_post_task "$subcmd"
        exit $?
      fi
      ;;
  esac

  # Run tasks.
  for task_with_args in "$@"
  do
    task_name="$task_with_args"
    args=""
    case "$task_with_args" in
      (*\[*)
        task_name="${task_with_args%%\[*}"
        args="$(echo "$task_with_args" | sed -r -e 's/^.*\[//' -e 's/\]$//' -e 's/,/ /')"
        ;;
    esac
    task_name="$(echo "$task_name" | sed -r -e 's/:/__/g')"
    if type task_"$task_name" > /dev/null 2>&1
    then
      # run_pre_task "task_$task_name"
      # shellcheck disable=SC2086
      task_"$task_name" $args
      # run_post_task "task_$task_name"
      continue
    fi
    case "$task_name" in
      (task_*)
        # run_pre_task "$task_name"
        # shellcheck disable=SC2086
        "$task_name" $args
        # run_post_task "$task_name"
        continue
        ;;
    esac
    if type delegate_tasks > /dev/null 2>&1
    then
      verbose && echo "Delegating to delegate_tasks: $task_with_args" >&2
      if delegate_tasks "$@"
      then
        continue
      else
        if ! test $? -eq "$rc_delegate_task_not_found"
        then
          exit 1
        fi
      fi
    fi
    if ! $skip_missing
    then
      echo "Unknown task: $task_with_args" >&2
    fi
    if ! $skip_missing && ! $ignore_missing
    then
      exit 1
    fi
  done
}

# Run the main function if this script is executed as task runner.
case "${0##*/}" in
  (task|task.sh)
    main "$@"
    ;;
esac
