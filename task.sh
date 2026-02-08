#!/usr/bin/env sh
# vim: set filetype=sh :
# shellcheck shell=sh
"${sourced_897a0c7-false}" && return 0; sourced_897a0c7=true

# Freezed. Do not edit.

. ./utils.lib.sh

# ==========================================================================
#region Constants

# Return code when a test is skipped
# shellcheck disable=SC2034
rc_test_skipped=10

#endregion

# ==========================================================================
#region Environment variables. If not set by the caller, they are set later in `tasksh_main`

# The path to the shell executable which is running this script.
: "${SH:=/bin/sh}"

# The path to the file which was called.
: "${ARG0:=}"

# Basename of the file which was called.
: "${ARG0BASE:=}"

# Directory in which the task files are located.
: "${TASKS_DIR:=}"

# The root directory of the project.
: "${PROJECT_DIR:=${0%/*}}"

# Verbosity flag.
: "${VERBOSE:=false}"

# Cache directory path for the task runner
: "${CACHE_DIR:=$HOME/.cache/task-sh}"
mkdir -p "$CACHE_DIR"

# For platforms other than Windows
: "${LOCALAPPDATA:=/}"

if ! test -d /etc/ssl
then
  export SSL_CERT_FILE="$CACHE_DIR"/cacert.pem
fi

#endregion

# ==========================================================================
#region IFS manipulation

# shellcheck disable=SC2034
readonly unit_sep=""

# # Unit separator (US), Information Separator One (0x1F)
# # shellcheck disable=SC2034
# readonly us=""
# # shellcheck disable=SC2034
# readonly is="$us"
# # shellcheck disable=SC2034
# readonly is1="$us"

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
readonly newline_char="
"

# To split paths.
set_ifs_slashes() {
  printf "/\\"
}

set_ifs_default() {
  printf ' \t\n\r'
}

set_ifs_blank() {
  printf ' \t'
}

#endregion

# ==========================================================================
#region Map (associative array) functions. "IFS-Separated Map"

# Put a value in an associative array implemented as a property list.
ifsm_put() {
  local key="$2"
  local value="$3"
  # shellcheck disable=SC2086
  set -- $1
  # First char of IFS
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
    test "$1" = "$key" && printf "%s" "$2" && return 0
    shift 2
  done
  return 1
}

# Keys of an associative array implemented as a property list.
ifsm_keys() {
  # shellcheck disable=SC2086
  set -- $1
  # First char of IFS
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
  # First char of IFS
  local delim="${IFS%"${IFS#?}"}"
  while test $# -gt 0
  do
    printf "%s%s" "$2" "$delim"
    shift 2
  done
}

#endregion

# ==========================================================================
#region Fetch and run a command from an archive

# Canonicalize `uname -s` result
uname_s() {
  local os_name; os_name="$(uname -s)"
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
# Usage: run_fetched_cmd [OPTIONS] -- [COMMAND_ARGS...]
# Options:
#   --name=NAME           Application name. Used as the directory name to store the command.
#   --ver=VERSION         Application version
#   --cmd=COMMAND         Command name to execute. If not specified, the application name is used.
#   --ifs=IFS             IFS to split the os_map and arch_map options. Default: $IFS
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
  local ifs=
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
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (name) name=$OPTARG;;
      (ver) ver=$OPTARG;;
      (cmd) cmd=$OPTARG;;
      (ifs) ifs=$OPTARG;;
      (os-map) os_map=$OPTARG;;
      (arch-map) arch_map=$OPTARG;;
      (ext) ext=$OPTARG;;
      (ext-map) ext_map=$OPTARG;;
      (url-template) url_template=$OPTARG;;
      (rel-dir-template) rel_dir_template=$OPTARG;;
      (print-dir) print_dir=true;;
      (macos-remove-signature) macos_remove_signature=true;;
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
    local ifs_saved=
    if test -n "$ifs"
    then
      ifs_saved="$IFS"
      IFS="$ifs"
    fi
    local ver="$ver"
    local os
    # shellcheck disable=SC2034
    os="$(map_os "$os_map")" || return $?
    local arch
    # shellcheck disable=SC2034
    arch="$(map_arch "$arch_map")" || return $?
    if test -z "$ext" -a -n "$ext_map"
    then
      ext="$(map_os "$ext_map")"
    fi
    if test -n "$ifs_saved"
    then
      IFS="$ifs_saved"
    fi
    local url; url="$(eval echo "$url_template")" || return $?
    init_temp_dir
    local out_file_path="$TEMP_DIR"/"$name""$ext"
    if ! curl --fail --location "$url" --output "$out_file_path"
    then
      echo "Failed to download: $url" >&2
      return 1
    fi
    local work_dir_path="$TEMP_DIR"/"$name"ec85463
    mkdir -p "$work_dir_path"
    push_dir "$work_dir_path"
    case "$ext" in
      (.zip) unzip "$out_file_path" >&2 ;;
      (.tar.gz) tar -xf "$out_file_path" >&2 ;;
      (*) ;;
    esac
    pop_dir
    if test -n "$ext"
    then
      local rel_dir_path; rel_dir_path="$(eval echo "$rel_dir_template")"
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
    PATH="$app_dir_path":$PATH invoke "$cmd_path" "$@"
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
""

# Uname kernel name -> GOOS in CamelCase mapping
# shellcheck disable=SC2140
# shellcheck disable=SC2034
goos_camel_map=\
"Linux Linux "\
"Darwin Darwin "\
"Windows Windows "\
""

# Uname architecture name -> GOARCH mapping
# shellcheck disable=SC2140
# shellcheck disable=SC2034
goarch_map=\
"x86_64 amd64 "\
"arm64 arm64 "\
"armv7l arm "\
"i386 386 "\
""

# Uname kernel name -> generally used archive file extension mapping
# shellcheck disable=SC2140
# shellcheck disable=SC2034
archive_ext_map=\
"Linux .tar.gz "\
"Darwin .tar.gz "\
"Windows .zip "\
""

#endregion

# ==========================================================================
#region Package command management

# Map: command name -> Homebrew package ID
usm_brew_ids=

# Map: command name -> WinGet package ID
usm_winget_ids=

# Map: command name -> Debian package ID
usm_deb_ids=

# Map: command name -> pipe-separated vector of commands
usm_psv_cmds=

# Register a command with optional package IDs for various package managers.
# This function maps a command name to package IDs for installation via different package managers.
# The remaining arguments are treated as the command paths to be tried in order. The last argument is treated as the command name.
# Options:
#   --brew-id=<id>    Package ID for Homebrew (macOS)
#   --deb-id=<id>     Package ID for Debian/Ubuntu package manager
#   --winget-id=<id>  Package ID for Windows Package Manager
require_pkg_cmd() {
  local name=
  local brew_id=
  local deb_id=
  local winget_id=
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (name) name="$OPTARG";;
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
  local psv_cmds=
  local cmd
  for cmd in "$@"
  do
    cmd_name="$cmd"
    psv_cmds="$psv_cmds$cmd|"
  done
  if test -n "$name"
  then
    cmd_name="$name"
  fi
  test -n "$brew_id" && usm_brew_ids="$usm_brew_ids$cmd_name$us$brew_id$us"
  test -n "$winget_id" && usm_winget_ids="$usm_winget_ids$cmd_name$us$winget_id$us"
  test -n "$deb_id" && usm_deb_ids="$usm_deb_ids$cmd_name$us$deb_id$us"
  usm_psv_cmds="$usm_psv_cmds$cmd_name$us$psv_cmds$us"
}

# Run registered, package-provided command. If the command is not found, print the instructions to install it.
run_pkg_cmd() {
  local cmd_name="$1"
  shift
  local saved_ifs="$IFS"; IFS="|"
  local cmd
  for cmd in $(IFS="$us" ifsm_get "$usm_psv_cmds" "$cmd_name")
  do
    if which "$cmd" >/dev/null
    then
      IFS="$saved_ifs"
      invoke "$cmd" "$@"
      return $?
    fi
  done
  IFS="$saved_ifs"
  echo "Command not found: $cmd_name." >&2
  echo >&2
  if is_macos
  then
    echo "Run the \"devinstall\" task or the following command to install necessary packages for this development environment:" >&2
    echo >&2
    printf "  brew install" >&2
    local saved_ifs="$IFS"; IFS="$us"
    # shellcheck disable=SC2046
    # shellcheck disable=SC2086
    printf " %s" $(ifsm_values "$usm_brew_ids") >&2
    IFS="$saved_ifs"
  elif is_windows
  then
    printf "  winget install" >&2
    local saved_ifs="$IFS"; IFS="$us"
    # shellcheck disable=SC2046
    # shellcheck disable=SC2086
    printf " %s" $(ifsm_values "$usm_winget_ids") >&2
    IFS="$saved_ifs"
  fi
  echo >&2
  echo >&2
  return 1
}

# Install necessary packages for this development environment.
task_devinstall() {
  if is_macos
  then
    set - brew install
    local saved_ifs="$IFS"; IFS="$us"
    # shellcheck disable=SC2046
    set -- "$@" $(ifsm_values "$usm_brew_ids")
    IFS="$saved_ifs"
    invoke "$@"
  elif is_windows
  then
    set - winget install
    local saved_ifs="$IFS"; IFS="$us"
    # shellcheck disable=SC2046
    set -- "$@" $(ifsm_values "$usm_winget_ids")
    IFS="$saved_ifs"
    invoke "$@"
  fi
}

#endregion

# ==========================================================================
#region Mise - Home | mise-en-place https://mise.jdx.dev/

# Releases · jdx/mise https://github.com/jdx/mise/releases
mise_version_adcf449="2026.1.12"

set_mise_version() {
  mise_version_adcf449="$1"
}

mise() {
  # shellcheck disable=SC2016
  run_fetched_cmd \
    --name="mise" \
    --ver="$mise_version_adcf449" \
    --os-map="Linux linux Darwin macos Windows windows " \
    --arch-map="x86_64 x64 arm64 arm64 " \
    --ext-map="$archive_ext_map" \
    --url-template='https://github.com/jdx/mise/releases/download/v${ver}/mise-v${ver}-${os}-${arch}${ext}' \
    --rel-dir-template='mise/bin' \
    -- \
    "$@"
}

# Run mise(1)
subcmd_mise() {
  mise "$@"
}

#endregion

# ==========================================================================
#region curl(1) // curl https://curl.se/

apt_helper_download() {
  local url="$1"
  local dest="$2"
  local apt_conf_path="$TEMP_DIR"/apt.conf
  printf "%s\n" \
    'Acquire::https::Verify-Peer "false";' \
    'Acquire::https::Verify-Host "false";' \
  >"$apt_conf_path"
  /usr/lib/apt/apt-helper -c "$apt_conf_path" download-file "$url" "$dest" 1>&2
}

curl() {
  if has_external_command curl >/dev/null 2>&1
  then
    invoke curl "$@"
    return
  fi
  local cmd_path="$CACHE_DIR"/curl"$exe_ext"
  if ! test -x "$cmd_path"
  then
    if is_linux && test -x /usr/lib/apt/apt-helper
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
      local arch
      case "$(uname -m)" in
        (x86_64) arch=amd64;;
        (aarch64) arch=aarch64;;
        (*) echo "Unsupported architecture: $(uname -m)" >&2; return 1;;
      esac
      local url="https://github.com/moparisthebest/static-curl/releases/download/$curl_version/curl-$arch"
      apt_helper_download "$url" "$cmd_path"
      if ! echo "$(echo "$curl_sha256sums" | grep "$(basename "$url")" | cut -d' ' -f1)" "$cmd_path" | sha256sum --check --status
      then
        echo "curl checksum mismatch." >&2
        return 1
      fi
      chmod +x "$cmd_path"
    else
      echo "No way to download curl." >&2
      return 1
    fi
  fi
  if ! test -d /etc/ssl
  then
    local ca_cert_path="$CACHE_DIR"/cacert.pem
    if ! test -r "$ca_cert_path"
    then
      # curl - Extract CA Certs from Mozilla https://curl.se/docs/caextract.html
      local cacert_url="https://curl.se/ca/cacert-2025-12-02.pem"
      local cacert_sha256sum="f1407d974c5ed87d544bd931a278232e13925177e239fca370619aba63c757b4"
      "$cmd_path" --insecure --fail --location --output "$CACHE_DIR"/cacert.pem "$cacert_url"
      if ! echo "$cacert_sha256sum" "$CACHE_DIR"/cacert.pem | sha256sum --check --status 1>&2
      then
        echo "cacert.pem checksum mismatch." >&2
        return 1
      fi
    fi
    # $SSL_CERT_FILE is set.
    # set -- --cacert "$ca_cert_path" "$@"
  fi
  "$cmd_path" "$@"
}

# Run curl(1).
subcmd_curl() {
  curl "$@"
}

#endregion

# ==========================================================================
#region jq(1) // jqlang/jq: Command-line JSON processor https://github.com/jqlang/jq

jq_prefer_pkg_ec51165=false

# Make use of jq(1) installed by a platform-specific package manager rather than the fetched binary.
jq_prefer_pkg() {
  jq_prefer_pkg_ec51165=true
  require_pkg_cmd \
    --brew-id=jq \
    --winget-id=jqlang.jq \
    /usr/local/bin/jq \
    "$LOCALAPPDATA"/Microsoft/WinGet/Links/jq.exe \
    jq
}

# Releases · jqlang/jq · GitHub https://github.com/jqlang/jq/releases
jq_version_6d4ce66=1.8.1

set_jq_version() {
  jq_version_6d4ce66="$1"
}

jq() {
  if is_windows
  then
    set -- --binary "$@"
  fi
  if "$jq_prefer_pkg_ec51165"
  then
    run_pkg_cmd jq "$@"
    return 0
  fi
  # shellcheck disable=SC2016
  run_fetched_cmd \
    --name="jq" \
    --ver="$jq_version_6d4ce66" \
    --os-map="Darwin macos $goos_map" \
    --arch-map="$goarch_map" \
    --url-template='https://github.com/jqlang/jq/releases/download/jq-$ver/jq-$os-$arch$exe_ext' \
    -- \
    "$@"
}

# Run jq(1).
subcmd_jq() {
  jq "$@"
}

#endregion

# ==========================================================================
#region .env* file management

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
    # Do not overwrite an existing, previously set value.
    if test -n "$value"
    then
      continue
    fi
    eval "$line"
  done <"$1"
}

# Load environment variables from .env* files
load_env() {
  first_call 8005f70 || return 0
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

#endregion

# ==========================================================================
#region Install/Update task-sh task scripts

github_prepare_token() {
  first_call b1929c9 || return 0
  if test "${GITHUB_TOKEN+set}" = set
  then
    echo "Using existing \$GITHUB_TOKEN environment variable." >&2
    return 0
  fi
  if command -v gh >/dev/null
  then
    if gh auth status >/dev/null
    then
      echo "Using GitHub token gh(1) provides." >&2
      GITHUB_TOKEN="$(gh auth token)"
      return 0
    fi
  fi
  echo "Accessing GitHub API with anonymous access." >&2
}

github_api_request() {
  local url="$1"
  github_prepare_token
  set -- \
    --silent \
    --header "X-GitHub-Api-Version: 2022-11-28" \
    --header "Accept: application/vnd.github+json" \
    --fail
  if test "${GITHUB_TOKEN+set}" = set
  then
    set -- "$@" --header "Authorization: Bearer $GITHUB_TOKEN"
  fi
  "$VERBOSE" && echo "Accessing GitHub API: $url" >&2
  curl "$@" "$url"
}

github_tree_get() {
  local owner=
  local repos=
  local tree_sha=main
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (owner) owner="$OPTARG";;
      (repos) repos="$OPTARG";;
      (branch|tag|tree|tree-sha) tree_sha="$OPTARG";;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  # REST API endpoints for Git trees - GitHub Docs https://docs.github.com/en/rest/git/trees
  local url
  url="$(printf "https://api.github.com/repos/%s/%s/git/trees/%s" "$owner" "$repos" "$tree_sha")"
  github_api_request "$url"
}

# Fetch raw content of a file from a GitHub repository
# Usage: github_raw_fetch [OPTIONS]
# Options:
#   --owner=OWNER         GitHub repository owner/organization
#   --repos=REPOS         GitHub repository name
#   --tree-sha=SHA        Tree SHA, branch name, or tag name (default: main). Aliases: --branch, --tag, --tree
#   --path=PATH           Path to the file within the repository
github_raw_fetch() {
  local owner=
  local repos=
  local tree_sha=main
  local path=
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (owner) owner="$OPTARG";;
      (repos) repos="$OPTARG";;
      (branch|tag|tree|tree-sha) tree_sha="$OPTARG";;
      (path) path="$OPTARG";;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  path="${path#/}"
  local url
  url="$(printf "https://raw.githubusercontent.com/%s/%s/%s/%s" "$owner" "$repos" "$tree_sha" "$path")"
  curl --fail --silent "$url"
}

state_path="$PROJECT_DIR/.task-sh-state.json"

# [<name>...] Install task-sh files. If no name is specified, lists available files.
subcmd_task__install() {
  local force=false
  if test "$#" -gt 0 && test "$1" = "--force"
  then
    shift
    force=true
  fi
  local rc=0
  local resp
  local main_branch=main
  resp="$(github_tree_get --owner="knaka" --repos="task-sh")"
  local latest_commit; latest_commit="$(printf "%s" "$resp" | jq -r .sha)"
  "$VERBOSE" && echo "Latest commit of \"$main_branch\" is \"$latest_commit\"." >&2
  if test $# = 0
  then
    echo "Available files:" >&2
    echo "$resp" \
    | jq -r '.tree[] | .path' \
    | grep -e '^[^._].*\.lib\.sh$' \
    | sed -e 's/^/  /'
    return
  fi
  if ! test -r "$state_path"
  then
    echo '{}' >"$state_path"
  fi
  local file
  local name
  for file in "$@"
  do
    name="${file##*/}"
    "$VERBOSE" && echo "Name: \"$name\"."
    local indent="  "
    local node mode last_sha
    local last_sha=
    last_sha="$(jq -r --arg name "$name" '.last_sha[$name] // ""' "$state_path")"
    "$VERBOSE" && echo "${indent}Last installed SHA:" "$last_sha"
    local local_sha=
    if test -r "$file"
    then
      local_sha="$(git hash-object "$file")"
    fi
    "$VERBOSE" && echo "${indent}Local SHA:" "$local_sha"
    if test -n "$last_sha" -a -n "$local_sha" -a "$last_sha" != "$local_sha"
    then
      echo "\"$name\" is modified locally." >&2
      rc=1
      continue
    fi
    if test "$file" = "$name"
    then
      case "$file" in
        (*/*) ;;
        (*) file="$TASKS_DIR"/"$name"
      esac
    fi
    node="$(echo "$resp" | jq -c --arg name "$name" '.tree[] | select(.path == $name)')"
    if test -z "$node"
    then
      echo "\"$name\" does not exist in the remote repository."
      rc=1
      continue
    fi
    local new_sha
    new_sha="$(echo "$node" | jq -r .sha)"
    "$VERBOSE" && echo "${indent}Remote SHA:" "$new_sha" >&2
    if ! "$force" && test -n "$local_sha" -a "$new_sha" = "$last_sha"
    then
      echo "\"$name\" is up to date. Skipping." >&2
      continue
    fi
    # shellcheck disable=SC2059
    printf "Downloading \"$name\" ... " >&2
    if test "$name" = "task.sh"
    then
      "$VERBOSE" && echo "Lazily replacing \"$file.new\" with \"$file\"." >&2
      chaintrap "mv \"$file.new\" \"$file\"" EXIT
      local file="$file.new"
    fi
    github_raw_fetch --owner="knaka" --repos="task-sh" --tree-sha="$latest_commit" --path=/"$name" >"$file"
    echo "done." >&2
    local temp_json="$TEMP_DIR"/1caef61.json
    jq --arg name "$name" --arg sha "$new_sha" '.last_sha[$name] = $sha' "$state_path" >"$temp_json"
    cat "$temp_json" >"$state_path"
    mode="$(echo "$node" | jq -r .mode)"
    "$VERBOSE" && echo "  Mode:" "$mode"
    chmod "${mode#???}" "$file"
  done
  return "$rc"
}

# Update task-sh files.
task_task__update() {
  local file
  local excludes=":"
  for file in "$TASKS_DIR"/project*.lib.sh
  do
    test -e "$file" || continue
    excludes="$excludes:$file:"
  done
  set --
  for file in "$TASKS_DIR"/*.lib.sh "$TASKS_DIR"/task.sh
  do
    test -r "$file" || continue
    case "$excludes" in
      (*:$file:*) continue;;
    esac
    set -- "$@" "$file"
  done
  subcmd_task__install "$INITIAL_PWD"/task "$INITIAL_PWD"/task.cmd "$@"
}

#endregion

# ==========================================================================
#region Main

sub_helps_e4c531b=""

# Add a function to print a sub help section
add_sub_help() {
  sub_helps_e4c531b="$sub_helps_e4c531b$1 "
}

psv_task_file_paths_4a5f3ab=

# Show task-sh help
tasksh_help() {
  cat <<EOF
Usage:
  $ARG0BASE [flags] <subcommand> [args...]
  $ARG0BASE [flags] <task[arg1,arg2,...]> [tasks...]

Flags:
  -d, --directory=<dir>  Change directory before running tasks.
  -h, --help             Display this help and exit.
  -v, --verbose          Verbose mode.
EOF
  # shellcheck disable=SC2086
  lines="$(
    IFS="|"
    awk \
      '
        /^#/ { 
          desc = $0
          gsub(/^#+[ ]*/, "", desc)
          next
        }
        /^(task_|subcmd_)[[:alnum:]_]()/ {
          func_name = $1
          sub(/\(\).*$/, "", func_name)
          type = func_name
          sub(/_.*$/, "", type)
          name = func_name
          sub(/^[^_]+_/, "", name)
          gsub(/__/, ":", name)
          basename = FILENAME
          sub(/^.*\//, "", basename)
          print type " " name " " basename " " desc
          desc = ""
          next
        }
        {
          desc = ""
        }
      ' \
      $psv_task_file_paths_4a5f3ab
  )"
  local i
  for i in subcmd task
  do
    echo
    if test "$i" = subcmd
    then
      echo "Subcommands:"
    else
      echo "Tasks:"
    fi
    local max_name_len; max_name_len="$(
      echo "$lines" \
      | while read -r t name _
        do
          test "$t" = "$i" || continue
          echo "${#name}"
        done \
      | sort -nr \
      | head -1
    )"
    echo "$lines" \
    | sort \
    | while read -r type name basename desc
      do
        test "$type" = "$i" || continue
        case "${basename}" in
          # Emphasize project tasks/subcommands, not shared ones.
          (project*.lib.sh)
            if is_terminal
            then
              # Underline
              padding_len=$((max_name_len - ${#name}))
              printf "  \033[4m%s\033[0m%-${padding_len}s  %s\n" "$name" "" "$desc"
            else
              # Asterisk
              printf "* %-${max_name_len}s  %s\n" "$name" "$desc"
            fi
            ;;
          (*)
            printf "  %-${max_name_len}s  %s\n" "$name" "$desc"
            ;;
        esac
      done
  done
  local sub_help
  for sub_help in $sub_helps_e4c531b
  do
    echo
    "$sub_help"
  done
}

# Execute a command in task.sh context.
subcmd_task__exec() {
  local saved_shell_flags; saved_shell_flags="$(set +o)"
  set +o errexit
  if alias "$1" >/dev/null 2>&1
  then
    # shellcheck disable=SC2294
    eval "$@"
  else
    "$@"
  fi
  echo "Exit status: $?" >&2
  eval "$saved_shell_flags"
}

usv_called_task_7ef15a7="$us"

# Call the task/subcommand. If the same task (including the arguments) has already been called, this returns immediately. Calls before/after hooks accordingly.
call_task() {
  local func_name="$1"
  shift
  local task_name=
  case "$func_name" in
    (task_*)
      local cmd_with_args="$func_name $*"
      case "$usv_called_task_7ef15a7" in
        (*"$us$cmd_with_args$us"*)
          return 0
          ;;
      esac
      usv_called_task_7ef15a7="$usv_called_task_7ef15a7$cmd_with_args$us"
      task_name="${func_name#task_}"
      ;;
    (subcmd_*) task_name="${func_name#subcmd_}";;
    (*) return 1;;
  esac
  local prefix
  prefix="$task_name"
  while :
  do
    if type "before_$prefix" >/dev/null 2>&1
    then
      "$VERBOSE" && echo "Calling before function:" "before_$prefix" "$func_name" "$@" >&2
      "before_$prefix" "$func_name" "$@" || return $?
    fi
    test -z "$prefix" && break
    case "$prefix" in
      (*__*) prefix="${prefix%__*}";;
      (*) prefix=;;
    esac
  done
  "$VERBOSE" && echo "Calling task function:" "$func_name" "$@" >&2
  if alias "$func_name" >/dev/null 2>&1
  then
    # shellcheck disable=SC2294
    eval "$func_name" "$@"
  else
    "$func_name" "$@"
  fi
  prefix="$task_name"
  while :
  do
    if type "after_$prefix" >/dev/null 2>&1
    then
      "$VERBOSE" && echo "Calling after function:" "after_$prefix" "$func_name" "$@" >&2
      "after_$prefix" "$func_name" "$@" || return $?
    fi
    case "$prefix" in
      (*__*) ;;
      (*) break;;
    esac
    prefix="${prefix%__*}"
  done
}

tasksh_main() {
  set -o nounset -o errexit

  defer_child_cleanup

  PROJECT_DIR="$(realpath "$PROJECT_DIR")"
  export PROJECT_DIR
  TASKS_DIR="$(realpath "$TASKS_DIR")"
  export TASKS_DIR

  # Before loading task files, permit running task:install to fetch and overwrite existing task files even when they cannot be loaded due to errors or missing `source`d files.
  if test "$#" -gt 0 && test "$1" = "task:install" -o "$1" = "subcmd_task__install"
  then
    shift
    subcmd_task__install "$@"
    return 0
  fi

  # Load all task files in the tasks directory. All task files are sourced in the $TASKS_DIR directory context.
  push_dir "$TASKS_DIR"
  local path
  for path in "$TASKS_DIR"/task.sh "$TASKS_DIR"/*.lib.sh
  do
    test -r "$path" || continue
    psv_task_file_paths_4a5f3ab="$psv_task_file_paths_4a5f3ab$path|"
    # shellcheck disable=SC1090
    . "$path"
  done
  pop_dir

  # Parse the command line arguments.
  shows_help=false
  skip_missing=false
  ignore_missing=false
  OPTIND=1; while getopts hvsi-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (h|help) shows_help=true;;
      (s|skip-missing) skip_missing=true;;
      (i|ignore-missing) ignore_missing=true;;
      (v|verbose)
        export VERBOSE=true
        ;;
      (\?) tasksh_help; exit 1;;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  # Show help message and exit.
  if $shows_help || test "$#" -eq 0
  then
    tasksh_help
    exit 0
  fi

  # Execute the subcommand and exit.
  local subcmd="$1"
  subcmd="$(echo "$subcmd" | sed -r -e 's/:/__/g')"
  if type subcmd_"$subcmd" >/dev/null 2>&1
  then
    shift
    if alias subcmd_"$subcmd" >/dev/null 2>&1
    then
      # shellcheck disable=SC2294
      call_task subcmd_"$subcmd" "$@"
      exit $?
    fi
    call_task subcmd_"$subcmd" "$@"
    exit $?
  fi
  # Called not by subcommand name but by function name.
  case "$subcmd" in
    (subcmd_*)
      if type "$subcmd" >/dev/null 2>&1
      then
        shift
        call_task "$subcmd" "$@"
        exit $?
      fi
      ;;
  esac

  # Run tasks.
  local task_with_args
  for task_with_args in "$@"
  do
    local task_name="$task_with_args"
    args=""
    case "$task_with_args" in
      # Task with arguments.
      (*\[*)
        task_name="${task_with_args%%\[*}"
        args="$(echo "$task_with_args" | sed -r -e 's/^.*\[//' -e 's/\]$//' -e 's/,/ /')"
        ;;
    esac
    task_name="$(echo "$task_name" | sed -r -e 's/:/__/g')"
    if type task_"$task_name" >/dev/null 2>&1
    then
      # shellcheck disable=SC2086
      call_task task_"$task_name" $args
      continue
    fi
    # Called not by task name but by task function name.
    case "$task_name" in
      (task_*)
        # shellcheck disable=SC2086
        call_task "$task_name" $args
        continue
        ;;
    esac
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
    tasksh_main "$@"
    ;;
esac

#endregion
