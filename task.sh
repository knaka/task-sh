#!/usr/bin/env sh
# vim: set filetype=sh :
# shellcheck shell=sh
"${sourced_897a0c7-false}" && return 0; sourced_897a0c7=true

# --------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------

# Return code when a delegate task does not provide the task
# shellcheck disable=SC2034
rc_delegate_task_not_found=10

# Return code when a test is skipped
# shellcheck disable=SC2034
rc_test_skipped=11

# --------------------------------------------------------------------------
# Temporary directory and cleaning up
# --------------------------------------------------------------------------

TEMP_DIR="$(mktemp -d)"
# shellcheck disable=SC2064
trap "rm -fr '$TEMP_DIR'" EXIT

# Base name of the script file containing the statements to be called during finalization
readonly stmts_file_base="$TEMP_DIR"/b6a5748

# Chain traps to avoid overwriting the previous trap.
# shellcheck disable=SC2064
chaintrap() {
  local stmts="$1"
  shift 
  local stmts_bak_file="$TEMP_DIR"/347803f
  local sigspec
  for sigspec in "$@"
  do
    # sigspec=$(echo "$sigspec" | tr '[:lower:]' '[:upper:]')
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

# Directory in which the task runner is located.
: "${TASK_SH_DIR:=}"
# echo TASK_SH_DIR: "$TASK_SH_DIR" >&2

# The root directory of the project.
: "${PROJECT_DIR:=}"
# echo PROJECT_DIR: "$PROJECT_DIR" >&2

# The path to the file which was called.
: "${ARG0:=}"

# Basename of the file which was called.
: "${ARG0BASE:=}"

# Verbosity flag.
: "${VERBOSE:=false}"

verbose() {
  "$VERBOSE"
}

# Cache directory path for the task runner
CACHE_DIR="$HOME/.cache/task-sh"
mkdir -p "$CACHE_DIR"

# Cache directory path for the task runner
cache_dir_path() {
  echo "$CACHE_DIR"
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

# Unit separator (US), Information Separator One (0x1F)
# shellcheck disable=SC2034
readonly us=""
# shellcheck disable=SC2034
readonly is="$us"
# shellcheck disable=SC2034
readonly is1="$us"

# Information Separator Two (0x1E)
# shellcheck disable=SC2034
readonly is2=""

# Information Separator Three (0x1D)
# shellcheck disable=SC2034
readonly is3=""

# Information Separator Four (0x1C)
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
    echo "Directory does not exist: $1" >&2
    return 1
  fi
  psv_dirs_4c15d80="$pwd|$psv_dirs_4c15d80"
}

# `popd` alternative.
pop_dir() {
  if test -z "$psv_dirs_4c15d80"
  then
    echo "Directory stack is empty" >&2
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
# Map (associative array) functions. "IFS-Separated Map"
# --------------------------------------------------------------------------

# Put a value in an associative array implemented as a property list.
ifsm_put() {
  local key="$2"
  local value="$3"
  # shellcheck disable=SC2086
  set -- $1
  local delim="${IFS%"${IFS#?}"}"
  while test $# -gt 0
  do
    test "$1" != "$key" && printf "%s%s%s%s" "$1" "$delim" "$2" "$delim"
    shift 2
  done
  printf "%s%s%s%s" "$key" "$delim" "$value" "$delim"
}

# Get a value from an associative array implemented as a property list.
ifsm_get() {
  local key="$2"
  # shellcheck disable=SC2086
  set -- $1
  while test $# -gt 0
  do
    test "$1" = "$key" && printf "%s" "$2" && return
    shift 2
  done
  return 1
}

# Keys of an associative array implemented as a property list.
ifsm_keys() {
  # shellcheck disable=SC2086
  set -- $1
  local delim="${IFS%"${IFS#?}"}"
  while test $# -gt 0
  do
    printf "%s%s" "$1" "$delim"
    shift 2
  done
}

# Values of an associative array implemented as a property list.
ifsm_values() {
  # shellcheck disable=SC2086
  set -- $1
  local delim="${IFS%"${IFS#?}"}"
  while test $# -gt 0
  do
    printf "%s%s" "$2" "$delim"
    shift 2
  done
}

# --------------------------------------------------------------------------
# Fetch and run a command from an archive
# --------------------------------------------------------------------------

uname_s() {
  local os_name="$(uname -s)"
  case "$os_name" in
    (Windows_NT|MINGW*|CYGWIN*) os_name="Windows" ;;
  esac
  echo "$os_name"
}

map_os() {
  ifsm_get "$1" "$(uname_s)"
}

map_arch() {
  ifsm_get "$1" "$(uname -m)"
}

# Fetch and run a command from a remote archive
# Usage: fetch_cmd_run [OPTIONS] -- [COMMAND_ARGS...]
# Options:
#   --name=NAME           Application name. Used as the directory name to store the command.
#   --ver=VERSION         Application version
#   --cmd=COMMAND         Command name to execute. If not specified, the application name is used.
#   --os-map=MAP          OS name mapping (IFS-separated key-value pairs)
#   --arch-map=MAP        Architecture name mapping (IFS-separated key-value pairs)
#   --ext=EXTENSION       Archive file extension (e.g., ".zip", ".tar.gz"). Takes precedence over --ext-map.
#   --ext-map=MAP         Archive extension mapping (IFS-separated key-value pairs). Used when --ext is not specified. If neither option is provided, the URL template points directly to a command binary rather than an archive file
#   --url-template=TEMPLATE URL template string to generate the download URL with ${ver}, ${os}, ${arch}, ${ext}, ${exe_ext} (=.exe on Windows) variables
#   --rel-dir-template=TEMPLATE   Relative path template within archive to the directory containing the command (default: ".")
#   --print-dir           Print the directory path where the command is installed instead of executing the command
#   --macos-remove-signature      Remove code signature from the downloaded binary on macOS to bypass security checks
run_fetched_cmd() {
  local name=
  local ver=
  local cmd=
  local os_map=
  local arch_map=
  local ext=
  local ext_map=
  local url_template=
  local rel_dir_template=.
  local print_dir=false
  local macos_remove_signature=false
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
      (name) name=$OPTARG;;
      (ver) ver=$OPTARG;;
      (cmd) cmd=$OPTARG;;
      (os-map) os_map=$OPTARG;;
      (arch-map) arch_map=$OPTARG;;
      (ext) ext=$OPTARG;;
      (ext-map) ext_map=$OPTARG;;
      (url-template) url_template=$OPTARG;;
      (rel-dir-template) rel_dir_template=$OPTARG;;
      (print-dir) print_dir=true;;
      (macos-remove-signature) macos_remove_signature=true;;
      (\?) exit 1;;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  if test -z "$cmd"
  then
    cmd="$name"
  fi
  local app_dir_path="$CACHE_DIR"/"$name"@"$ver"
  mkdir -p "$app_dir_path"
  local cmd_path="$app_dir_path"/"$cmd""$exe_ext"
  if ! command -v "$cmd_path" >/dev/null 2>&1
  then
    local ver="$ver"
    # shellcheck disable=SC2034
    local os="$(map_os "$os_map")"
    # shellcheck disable=SC2034
    local arch="$(map_arch "$arch_map")"
    if test -z "$ext" -a -n "$ext_map"
    then
      ext="$(map_os "$ext_map")"
    fi
    local url="$(eval echo "$url_template")"
    local out_file_path="$TEMP_DIR"/"$name""$ext"
    if ! curl --fail --location "$url" --output "$out_file_path"
    then
      echo Failed to download: "$url" >&2
      return 1
    fi
    local work_dir_path="$TEMP_DIR"/"$name"ec85463
    mkdir -p "$work_dir_path"
    push_dir "$work_dir_path"
    case "$ext" in
      (.zip) unzip "$out_file_path" ;;
      (.tar.gz) tar -xf "$out_file_path" ;;
      (*) ;;
    esac
    pop_dir
    if test -n "$ext"
    then
      local rel_dir_path="$(eval echo "$rel_dir_template")"
      mv "$work_dir_path"/"$rel_dir_path"/* "$app_dir_path"
    else
      mv "$out_file_path" "$cmd_path"
    fi
    chmod +x "$cmd_path"
    if is_macos && "$macos_remove_signature"
    then
      codesign --remove-signature "$cmd_path"
    fi
  fi
  if "$print_dir"
  then
    echo "$app_dir_path"
  else
    "$cmd_path" "$@"
  fi
}

# Uname kernel name -> GOOS mapping
# Installing Go from source - The Go Programming Language https://go.dev/doc/install/source#environment
# shellcheck disable=SC2140
# shellcheck disable=SC2034
goos_map=\
"Linux linux "\
"Darwin darwin "\
"Windows windows "\
#nop

# Uname kernel name -> GOOS in CamelCase mapping
# shellcheck disable=SC2140
# shellcheck disable=SC2034
goos_camel_map=\
"Linux Linux "\
"Darwin Darwin "\
"Windows Windows "\
#nop

# Uname architecture name -> GOARCH mapping
# shellcheck disable=SC2140
# shellcheck disable=SC2034
goarch_map=\
"x86_64 amd64 "\
"aarch64 arm64 "\
"armv7l arm "\
"i386 386 "\
#nop

# Uname kernel name -> generally used archive file extension mapping
# shellcheck disable=SC2140
# shellcheck disable=SC2034
archive_ext_map=\
"Linux .tar.gz "\
"Darwin .tar.gz "\
"Windows .zip "\
#nop

# --------------------------------------------------------------------------
# Package command registration
# --------------------------------------------------------------------------

# Map: command name -> Homebrew package ID
usm_brew_id=

# Map: command name -> WinGet package ID
usm_winget_id=

# Map: command name -> Debian package ID
usm_deb_id=

# Map: command name -> pipe-separated vector of commands
usm_psv_cmd=

# Register a command with optional package IDs for various package managers.
# This function maps a command name to package IDs for installation via different package managers.
# The rest arguments are treated as the command paths to be tried in order. The last argument is treated as the command name.
# Options:
#   --brew-id=<id>    Package ID for Homebrew (macOS)
#   --deb-id=<id>     Package ID for Debian/Ubuntu package manager
#   --winget-id=<id>  Package ID for Windows Package Manager
require_pkg_cmd() {
  local brew_id=
  local deb_id=
  local winget_id=
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
      (brew-id) brew_id=$OPTARG;;
      (deb-id) deb_id=$OPTARG;;
      (winget-id) winget_id=$OPTARG;;
      (\?) exit 1;;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  # Last argument is treated as the command name.
  local cmd_name=
  local psv_cmd=
  local cmd
  for cmd in "$@"
  do
    cmd_name="$cmd"
    psv_cmd="$psv_cmd|$cmd"
  done
  test -n "$brew_id" && usm_brew_id="$usm_brew_id$cmd_name$us$brew_id$us"
  test -n "$winget_id" && usm_winget_id="$usm_winget_id$cmd_name$us$winget_id$us"
  test -n "$deb_id" && usm_deb_id="$usm_deb_id$cmd_name$us$deb_id$us"
  usm_psv_cmd="$usm_psv_cmd$cmd_name$us$psv_cmd$us"
}

# For Windows
: "${LOCALAPPDATA:=e06a91c}"

run_pkg_cmd() {
  local cmd_name="$1"
  shift
  local saved_IFS="$IFS"; IFS="|"
  local cmd
  for cmd in $(IFS="$us" ifsm_get "$usm_psv_cmd" "$cmd_name")
  do
    if which "$cmd" >/dev/null
    then
      IFS="$saved_IFS"
      invoke "$cmd" "$@"
      return $?
    fi
  done
  IFS="$saved_IFS"
  echo "Command not found: $cmd_name." >&2
  echo >&2
  if is_macos
  then
    echo "Run \"devinstall\" task or the following command to install necessary packages for this development environment:" >&2
    echo >&2
    printf "  brew install" >&2
    local saved_ifs="$IFS"; IFS="$us"
    # shellcheck disable=SC2046
    # shellcheck disable=SC2086
    printf " %s" $(ifsm_values "$usm_brew_id") >&2
    IFS="$saved_ifs"
  elif is_windows
  then
    printf "  winget install" >&2
    local saved_ifs="$IFS"; IFS="$us"
    # shellcheck disable=SC2046
    # shellcheck disable=SC2086
    printf " %s" $(ifsm_values "$usm_winget_id") >&2
    IFS="$saved_ifs"
  fi
  echo >&2
  echo >&2
  return 1
}

task_devinstall() { # Install necessary packages for this development environment.
  if is_macos
  then
    set - brew install
    local saved_ifs="$IFS"; IFS="$us"
    # shellcheck disable=SC2046
    set -- "$@" $(ifsm_values "$usm_brew_id")
    IFS="$saved_ifs"
    invoke "$@"
  elif is_windows
  then
    set - winget install
    local saved_ifs="$IFS"; IFS="$us"
    # shellcheck disable=SC2046
    set -- "$@" $(ifsm_values "$usm_winget_id")
    IFS="$saved_ifs"
    invoke "$@"
  fi
}

# --------------------------------------------------------------------------
# Fetching
# --------------------------------------------------------------------------

# curl(1) is available on MacOS and Window as default.
require_pkg_cmd \
  --deb-id=curl \
  curl

curl() {
  run_pkg_cmd curl "$@"
}

subcmd_curl() { # Run curl(1).
  curl "$@"
}

# --------------------------------------------------------------------------
# Environment variable management
# --------------------------------------------------------------------------

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

# Load environment variables from multiple files
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

# --------------------------------------------------------------------------
# Misc
# --------------------------------------------------------------------------

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

exe_ext=
if is_windows
then
  # shellcheck disable=SC2034
  exe_ext=".exe"
fi

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

# Check if the file(s)/directory(s) are newer than the destination.
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
    echo "Missing --than option" >&2
    exit 1
  fi
  if test "$#" -eq 0
  then
    echo "No source files specified" >&2
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
    echo "No destination file found" >&2
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
# Invocation mode can be specified via INVOCATION_MODE environment variable:
#   INVOCATION_MODE=exec: Replace the process with the command.
#   INVOCATION_MODE=exec-sub: Replace the process with the command, without calling cleanups.
#   INVOCATION_MODE=background: Run the command in the background.
#   INVOCATION_MODE=standard: Run the command in the current process.
invoke() {
  local invocation_mode="${INVOCATION_MODE:-standard}"
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
    (background) command "$@" &;;
    (standard)
      command "$@"
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

# Get a key from the user without echoing.
get_key() {
  if is_linux || is_macos
  then
    local saved_stty="$(stty -g)"
    stty -icanon -echo
    dd bs=1 count=1 2>/dev/null
    stty "$saved_stty"
    return
  fi
  local key
  # Bash and BusyBox Ash provides `-s` (silent mode) option.
  if test is_ash || is_bash
  then
    # shellcheck disable=SC3045
    read -rsn1 key
  # Otherwise, the input is echoed
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
    echo "File $file_path already exists. Skipping creation." >&2
    return 0
  fi
  echo "Creating file $file_path." >&2
  mkdir -p "$(dirname "$file_path")"
  cat >"$file_path"
}

# Guard against multiple calls. $1 is a unique ID
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

# Get the space-separated nth (1-based) field.
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

# Encode positional parameters into a string that can be passed to `eval` to restore the positional parameters.
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

# Check if a directory is empty.
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

task_sh_usage() ( # Show help message.
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

subcmd_task__exec() { # Execute a command in task.sh context.
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
    # TASKS_DIR="$(realpath "$(dirname "$0")")"
    TASKS_DIR="$(dirname "$0")"
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
          echo "Project directory not found" >&2
          exit 1
        fi
        dir="$parent_dir"
      done
    fi
    export PROJECT_DIR
  fi

  PROJECT_REL_DIR="${PROJECT_DIR#"$TASK_SH_DIR/"}"
  if test "$PROJECT_REL_DIR" = "$PROJECT_DIR"
  then
    PROJECT_REL_DIR=""
  fi
  # echo "PROJECT_REL_DIR: $PROJECT_REL_DIR" >&2

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

  # Load all task files in the tasks directory and the project directory. All task files are sourced in the TASKS directory context.
  psv_task_file_paths_4a5f3ab="$(realpath "$0")|"
  load_tasks_in_dir() {
    push_dir "$TASKS_DIR"
    local project_rel_prefix="$PROJECT_REL_DIR"
    if test -n "$project_rel_prefix"
    then
      project_rel_prefix="$project_rel_prefix."
    fi
    case "$project_rel_prefix" in
      (*/*) project_rel_prefix="$(echo "$project_rel_prefix" | sed -E -e 's/\/$/./')" ;;
    esac
    # echo Checking tasks in "$project_rel_dir" >&2
    if test -r "$1"/"${project_rel_prefix}project.lib.sh"
    then
      # echo Loading "$1"/"${project_rel_prefix}project.lib.sh" >&2
      # ls -l "$1"/"${project_rel_dir}project.lib.sh" >&2
      psv_task_file_paths_4a5f3ab="$psv_task_file_paths_4a5f3ab$1/${project_rel_prefix}project.lib.sh|"
      # shellcheck disable=SC1090
      . "$1"/"${project_rel_prefix}project.lib.sh"
    fi
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
      (\?) task_sh_usage; exit 1;;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  # Show help message and exit.
  if $shows_help || test "${1+set}" != "set"
  then
    task_sh_usage
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
