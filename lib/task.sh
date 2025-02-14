# vim: set filetype=sh :
# shellcheck shell=sh
test "${sourced_897a0c7-}" = true && return 0; sourced_897a0c7=true

# Update this script by replacing itself with the latest version.
if test "${1+set}" = set && test "$1" = "update-me"
then
  temp_dir_path_6856fe8="$(mktemp -d)"
  # shellcheck disable=SC2317
  cleanup_7f0c4de() { rm -fr "$temp_dir_path_6856fe8"; }
  trap cleanup_7f0c4de EXIT
  curl_cmd_9f94dce=curl
  command -v curl.exe && curl_cmd_9f94dce=curl.exe
  "$curl_cmd_9f94dce" --fail --location --output "$temp_dir_path_6856fe8"/8c7b96d https://raw.githubusercontent.com/knaka/src/main/lib/task.sh
  cat "$temp_dir_path_6856fe8"/8c7b96d >"$0"
  exit 0
fi

# --------------------------------------------------------------------------
# Constants.
# --------------------------------------------------------------------------

# shellcheck disable=SC2034
rc_delegate_task_not_found=10

# shellcheck disable=SC2034
rc_test_skipped=11

# --------------------------------------------------------------------------
# Directories.
# --------------------------------------------------------------------------

# Original directory in which the script is invoked.

ORIGINAL_DIR="$PWD"
export ORIGINAL_DIR

# Directory in which the main script is located.

SCRIPT_DIR="$(realpath "$(dirname "$0")")"
export SCRIPT_DIR

# Check if the working directory is in the script directory.
in_script_dir() {
  realpath "$PWD" | grep -q -e "^$SCRIPT_DIR$" -e "^$SCRIPT_DIR/"
}

# --------------------------------------------------------------------------
# Misc
# --------------------------------------------------------------------------

# Create a temporary directory if required.

# Ash does not support `-t prefix`.
temp_dir_path_d4a4197="$(mktemp -d --dry-run)"

temp_dir_path() {
  if ! test -d "$temp_dir_path_d4a4197"
  then
    mkdir -p "$temp_dir_path_d4a4197"
  fi
  echo "$temp_dir_path_d4a4197"
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

oct_dump() {
  od -A n -t o1 -v | xargs printf "%s "
}

oct_restore() {
  xargs printf '\\\\0%s\n' | xargs printf '%b'
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

dirs_4c15d80=

# `pushd` alternative.
push_dir() {
  local pwd="$PWD"
  if ! cd "$1"
  then
    echo "No such directory: $1" >&2
    return 1
  fi
  dirs_4c15d80="$pwd|$dirs_4c15d80"
}

# `popd` alternative.
pop_dir() {
  if test -z "$dirs_4c15d80"
  then
    echo "Directory stack is empty." >&2
    return 1
  fi
  local dir="${dirs_4c15d80%%|*}"
  dirs_4c15d80="${dirs_4c15d80#*|}"
  cd "$dir" || return 1
}

# --------------------------------------------------------------------------
# Utility functions.
# --------------------------------------------------------------------------s

if ! type shuf > /dev/null 2>&1
then
  alias shuf='sort -R'
fi

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

is_linux() {
  test "$(uname -s)" = "Linux"
}

is_bsd() {
  stat -f "%z" . > /dev/null 2>&1
}

is_macos() {
  test "$(uname -s)" = "Darwin"
}

is_darwin() {
  test "$(uname -s)" = "Darwin"
}

is_windows() {
  case "$(uname -s)" in
    (Windows_NT|CYGWIN*|MINGW*|MSYS*) return 0 ;;
  esac
  return 1
}

# Executable file extension.
exe_ext() {
  if is_windows
  then
    echo ".exe"
  fi
}

is_alpine() {
  if test -f /etc/alpine-release
  then
    return 0
  fi
  return 1
}

# Memoize the command output.
memoize() {
  local cache_file_path
  cache_file_path="$(temp_dir_path)/$1"
  shift
  if ! test -r "$cache_file_path"
  then
    "$@" >"$cache_file_path"
  fi
  cat "$cache_file_path"
}

shell_name_f0ebcb7() {
  if test "${BASH+set}" = set
  then
    echo "bash"
    return
  # Busybox Ash shell on Windows sets $SHELL to provide the virtual executable path `/bin/sh`.
  elif is_windows && test "${SHELL+set}" = set && test "$SHELL" = "/bin/sh" && "$SHELL" --help 2>&1 | grep -q "BusyBox"
  then
    echo "ash"
    return
  fi
  local sh=
  if test -e /proc/$$/exe
  then
    sh="$(basename "$(readlink -f /proc/$$/exe)")" || return 1
  else
    sh="$(basename "$(ps -p $$ -o comm=)")" || return 1
  fi
  case "$sh" in
    (sh|busybox)
      if "$sh" --help 2>&1 | grep -q "BusyBox"
      then
        sh="ash"
      fi
      ;;
  esac
  echo "$sh"
}

shell_name() {
  memoize c3dcd27 shell_name_f0ebcb7
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
  test -n "$(find "$@" -newer "$dest" 2> /dev/null)"
}

# Invoke command with the specified invocation mode.
# 
#   --invocation-mode=exec: Replace the process with the command.
#   --invocation-mode=exec-sub: Replace the process with the command, without calling clearups.
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
        local ext
        for ext in .exe .cmd .bat
        do
          if test -x "$1$ext"
          then
            shift
            set -- "$1$ext" "$@"
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
        local ext
        for ext in .exe .cmd .bat
        do
          if command -v "$1$ext"
          then
            shift
            set -- "$1$ext" "$@"
            break
          fi
        done
      fi
      if ! command -v "$1" >/dev/null
      then
        echo "Command not found: $1" >&2
        exit 1
      fi
      ;;
  esac
  case "$invocation_mode" in
    (exec)
      cleanup
      exec "$@"
      ;;
    (exec-sub) exec "$@";;
    (background) "$@" &;;
    (standard) "$@";;
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

run_pkg_cmd() { # Run a command after ensuring it is installed.
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
  local apt_conf_path="$(temp_dir_path)"/apt.conf
  printf "%s\n" \
    'Acquire::https::Verify-Peer "false";' \
    'Acquire::https::Verify-Host "false";' \
    >"$apt_conf_path"
  /usr/lib/apt/apt-helper -c "$apt_conf_path" download-file "$1" "$2" 1>&2
}

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

subcmd_fetch() { # Fetch a URL.
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
    # No to overwrite.
    if test -n "$value"
    then
      continue
    fi
    eval "$line"
  done < "$1"
}

# Load environment variables.
load_env() {
  # Load the files in the order of priority.
  if test "${APP_ENV+set}" = set
  then
    load_env_file "$SCRIPT_DIR"/.env."$APP_ENV".dynamic
    load_env_file "$SCRIPT_DIR"/.env."$APP_ENV".local
  fi
  if test "${APP_ENV+set}" != set || test "${APP_ENV}" != "test"
  then
    load_env_file "$SCRIPT_DIR"/.env.dynamic
    load_env_file "$SCRIPT_DIR"/.env.local
  fi
  if test "${APP_ENV+set}" = set
  then
    load_env_file "$SCRIPT_DIR"/.env."$APP_ENV"
  fi
  # shellcheck disable=SC1091
  load_env_file "$SCRIPT_DIR"/.env
}

# Get a key from the user without echoing.
get_key() {
  if is_linux || is_macos
  then
    stty -icanon -echo
    dd bs=1 count=1 2>/dev/null
    stty icanon echo
    return
  fi
  local key
  # Bash POSIX and BusyBox ash provides `-s` (silent mode) option.
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
      printf "%s%s%s" "$pre" "$(emph "$char_to_emph")" "$post"
    else
      printf "%s" "$pre"
    fi
  ) | sed -E -e 's/@ampersand_ff37f3a@/\&/g'
  echo
}

# Print a menu
menu() {
  echo
  local arg
  for arg in "$@"
  do
    menu_item "$arg"
  done
}

# Sort in random order.
sort_random() {
  if type shuf > /dev/null 2>&1
  then
    shuf
  else
    sort -R
  fi
}

# Get the space-separated n-th (1-based) field.
field() (
  unset IFS
  # shellcheck disable=SC2046
  printf "%s\n" $(cat) | head -n "$1" | tail -n 1
)

# Mac does not have tac(1).
if ! type tac > /dev/null 2>&1
then
  tac() {
    tail -r
  }
fi

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

kill_child_processes() {
  if is_windows && is_ash
  then
    # Windows BusyBox ash
    # If the process is killed with pid, ash does not kill `exec`ed subprocesses.
    local jids
    jids="$(temp_dir_path)"/jids
    # ash provides “jobs pipe”.
    jobs | sed -E -e 's/^[^0-9]*([0-9]+).*Running *(.*)/\1/' >"$jids"
    while read -r jid
    do
      kill "%$jid" || :
      wait "%$jid" || :
      echo Killed "%$jid" >&2
    done <"$jids"
    return
  elif is_macos
  then
    pkill -P $$ || :
    return
  elif is_linux
  then
    if is_bash
    then
      local jids
      jids="$(temp_dir_path)"/jids
      # Bash provides “jobs pipe”.
      jobs | sed -E -e 's/^[^0-9]*([0-9]+).*Running *(.*)/\1/' >"$jids"
      while read -r jid
      do
        kill "%$jid" || :
        wait "%$jid" || :
        echo Killed "%$jid" >&2
      done <"$jids"
      return
    else
      pkill -P $$ || :
      return
    fi
  fi
  echo "kill_child_processes: Unsupported platform or shell." >&2
  exit 1
}

cleanup_handlers_2181b77=

# Main cleanup function. This does not `exit`.
cleanup() {
  kill_child_processes

  # Call cleanup handlers.
  local cleanup_handler
  for cleanup_handler in $cleanup_handlers_2181b77
  do
    "$cleanup_handler"
  done
  cleanup_handlers_2181b77=

  # Remove temporary directories.
  if test -d "$temp_dir_path_d4a4197"
  then
    rm -fr "$temp_dir_path_d4a4197"
  fi
}

# Exit handler.
on_exit() {
  local rc="$?"
  cleanup
  exit "$rc"
}

# Add a cleanup handler, not replacing the existing ones.
add_cleanup_handler() {
  cleanup_handlers_2181b77="${cleanup_handlers_2181b77:+$cleanup_handlers_2181b77 }$1"
}

# Verbosity flag.

verbose_f26120b=false 

verbose() {
  "$verbose_f26120b"
}

psv_task_file_paths=

task_subcmds() ( # List subcommands.
  lines="$(
    (
      IFS="|"
      # shellcheck disable=SC2086
      sed -E -n -e 's/^subcmd_([[:alnum:]_]+)\(\) *[{(] *(# *(.*))?/\1 \3/p' $psv_task_file_paths
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
      sed -E -n -e 's/^task_([[:alnum:]_]+)\(\) *[{(] *(# *(.*))?/\1 \3/p' $psv_task_file_paths
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

# Base name of the shell executable.
: "${SH:=}"
export SH

get_sh() {
  echo "$SH"
}

main() {
  set -o nounset -o errexit

  local sh
  sh="$(shell_name)"
  while true
  do
    if is_windows
    then
      if test "$sh" = "ash"
      then
        break
      fi
    elif is_macos
    then
      if test "$sh" = "dash"
      then
        break
      fi
    elif is_linux
    then
      case "$sh" in
        (ash|dash|bash)
          break
          ;;
      esac
    fi
    echo "Unsupported environment: $(uname -s)", "$sh" >&2
    exit 1
  done
  SH="$sh"
  export SH

  # Set the exit handlers caller.
  # Bash3 of macOS exits successfully if `nounset` error is trapped.
  trap on_exit EXIT TERM INT

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

  # Load all the task files in the script directory.
  psv_task_file_paths="$(realpath "$0")|"
  push_dir "$SCRIPT_DIR"
  for task_file_path in "$SCRIPT_DIR"/task_*.sh "$SCRIPT_DIR"/task-*.sh
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
    psv_task_file_paths="$psv_task_file_paths$task_file_path|"
    # echo Loading "$task_file_path" >&2
    # shellcheck disable=SC1090
    . "$task_file_path"
  done
  pop_dir

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
      (v|verbose) verbose_f26120b=true;;
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
if test "$(basename "$0")" = "task.sh"
then
  main "$@"
fi
