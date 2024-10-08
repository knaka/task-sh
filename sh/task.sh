#!/bin/sh
set -o nounset -o errexit

test "${guard_6ee3caf+set}" = set && return 0; guard_6ee3caf=x

if test "${1+SET}" = SET && test "$1" = "update-me"
then
  temp_dir_path_5de91af="$(mktemp -d)"
  # shellcheck disable=SC2317
  cleanup_7f0c4de() { rm -fr "$temp_dir_path_5de91af"; }
  trap cleanup_7f0c4de EXIT
  curl --fail --location --output "$temp_dir_path_5de91af"/task_sh https://raw.githubusercontent.com/knaka/src/main/task.sh
  cat "$temp_dir_path_5de91af"/task_sh > "$0"
  exit 0
fi

ORIGINAL_DIR="$PWD"
export ORIGINAL_DIR

chdir_original() {
  cd "$ORIGINAL_DIR" || exit 1
}

SCRIPT_DIR="$(realpath "$(dirname "$0")")"
export SCRIPT_DIR

chdir_script() {
  cd "$SCRIPT_DIR" || exit 1
}

user_specified_directory=

chdir_user() {
  if test -n "$user_specified_directory"
  then
    cd "$user_specified_directory" || exit 1
  else
    chdir_original
  fi
}

in_script_dir() {
  echo "$PWD" | grep -q "^$SCRIPT_DIR"
}

# busybox not supports -t
_temp_dir_path_d4a4197="$(mktemp -d --dry-run)"

temp_dir_path() {
  if ! test -d "$_temp_dir_path_d4a4197"
  then
    mkdir -p "$_temp_dir_path_d4a4197"
  fi
  echo "$_temp_dir_path_d4a4197"
}

if ! type tac > /dev/null 2>&1
then
  tac() {
    tail -r
  }
fi

cleanup() {
  # On some systems, `kill` cannot detect the process if `jobs` is not called before it.
  if is_windows 
  then
    for i_519fa93 in $(seq 10)
    do
      kill "%$i_519fa93" > /dev/null 2>&1 || :
      wait "%$i_519fa93" > /dev/null 2>&1 || :
    done
  else 
    for i_519fa93 in $(jobs | tac | sed -E -e 's/^\[([0-9]+).*/\1/')
    do
      kill "%$i_519fa93"
      wait "%$i_519fa93" || :
    done
    # for pid_7e44bc0 in $(jobs -p | tail -r)
    # do
    #   kill "$pid_7e44bc0"
    #   wait "$pid_7e44bc0" > /dev/null 2>&1 || :
    # done
    # jobs -p | tail -r | while read -r pid
    # do
    #   kill "$pid" > /dev/null 2>&1 || :
    #   wait "$pid" > /dev/null 2>&1 || :
    # done
  fi
  # echo "Killed children." >&2

  rm -fr "$_temp_dir_path_d4a4197"
  # echo "Cleaned up temporary files." >&2
}

trap cleanup EXIT

# --------------------------------------------------------------------------

is_windows() {
  case "$(uname -s)" in
    Windows_NT|CYGWIN*|MINGW*|MSYS*) return 0 ;;
    *) return 1 ;;
  esac
}

exe_ext() {
  if is_windows
  then
    echo ".exe"
  fi
}

is_bsd() {
  if stat -f "%z" . > /dev/null 2>&1
  then
    return 0
  fi
  return 1
  # case "$(uname -s)" in
  #   Darwin|FreeBSD|NetBSD|OpenBSD) return 0 ;;
  #   *) return 1 ;;
  # esac
}

set_path_attr() (
  path="$1"
  attribute="$2"
  value="$3"
  if which xattr > /dev/null 2>&1
  then
    xattr -w "$attribute" "$value" "$path"
  elif which PowerShell > /dev/null 2>&1
  then
    PowerShell -Command "Set-Content -Path '$path' -Stream '$attribute' -Value '$value'"
  elif which attr > /dev/null 2>&1
  then
    attr -s "$attribute" -V "$value" "$path"
  fi
)

file_sharing_ignorance_attributes="com.dropbox.ignored com.apple.fileprovider.ignore#P"

set_sync_ignored() (
  sync_ignorance_file="$SCRIPT_DIR"/.syncignored
  if ! test -r "$sync_ignorance_file"
  then
    touch "$sync_ignorance_file"
    set_sync_ignored "$sync_ignorance_file"
    if ! grep -q "^/\.syncignored\$" "$SCRIPT_DIR/.gitignore" > /dev/null 2>&1
    then
      echo "/.syncignored" >> "$SCRIPT_DIR/.gitignore"
    fi
  fi
  for path in "$@"
  do
    if ! test -e "$path"
    then
      continue
    fi
    rel_path="${path#"$SCRIPT_DIR"/}"
    if ! grep -q "^$rel_path/*\$" "$sync_ignorance_file"
    then
      # shellcheck disable=SC2154
      for attribute in $file_sharing_ignorance_attributes
      do
        set_path_attr "$path" "$attribute" 1
      done
      echo "$rel_path" >> "$sync_ignorance_file"
    fi
  done
)

newer() (
  found_than=false
  dest=
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
  # echo "74476d8 | dest: $dest, newer: $(find "$@" -newer "$dest")" >&2
  test -n "$(find "$@" -newer "$dest" 2> /dev/null)"
)

# Busybox sh seems to fail to detect proper executable if POSIX style one exists in the same directory.
cross_exec() {
  cleanup
  if ! is_windows
  then
    exec "$@"
  fi
  if ! test "${1+set}" = set
  then
    exit 1
  fi
  cmd_path="$1"
  shift
  if type "$cmd_path.exe" >/dev/null 2>&1
  then
    exec "$cmd_path.exe" "$@"
  fi
  if type "$cmd_path.cmd" >/dev/null 2>&1
  then
    exec "$cmd_path.cmd" "$@"
  fi
  if type "$cmd_path.bat" >/dev/null 2>&1
  then
    exec "$cmd_path.bat" "$@"
  fi
  exec "$cmd_path" "$@"
}

cross_run() (
  if ! is_windows
  then
    "$@"
    return $?
  fi
  cmd="$1"
  shift
  for ext in .exe .cmd .bat
  do
    if type "$cmd$ext" > /dev/null 2>&1
    then
      "$cmd$ext" "$@"
      return $?
    fi
  done
  "$cmd" "$@"
)

ensure_opt_arg() (
  if test -z "$2"
  then
    echo "No argument for option --$1." >&2
    usage
    exit 2
  fi
  echo "$2"
)

open_browser() (
  case "$(uname -s)" in
    Linux)
      xdg-open "$1" ;;
    Darwin)
      open "$1" ;;
    Windows_NT)
      start "$1" ;;
    *)
      echo "Unsupported OS: $(uname -s)" >&2
      exit 1
      ;;
  esac
)

run_installed() (
  cmd_name=
  winget_id=
  win_cmd_path=
  brew_id=
  brew_cmd_path=
  no_exec=false
  while getopts nc:p:b:P:w:-: OPT
  do
    if test "$OPT" = "-"
    then
      OPT="${OPTARG%%=*}"
      # shellcheck disable=SC2030
      OPTARG="${OPTARG#"$OPT"}"
      OPTARG="${OPTARG#=}"
    fi
    case "$OPT" in
      n|no-exec|install-only) no_exec=true;;
      b|brew-id) brew_id="$(ensure_opt_arg "$OPT" "$OPTARG")";;
      B|brew-cmd-path) brew_cmd_path="$(ensure_opt_arg "$OPT" "$OPTARG")";;
      c|cmd) cmd_name="$(ensure_opt_arg "$OPT" "$OPTARG")";;
      w|winget-id) winget_id="$(ensure_opt_arg "$OPT" "$OPTARG")";;
      p|winget-cmd-path) win_cmd_path="$(ensure_opt_arg "$OPT" "$OPTARG")";;
      \?) usage; exit 2;;
      *) echo "Unexpected option: $OPT" >&2; exit 2;;
    esac
  done
  shift $((OPTIND-1))

  cmd_path="$cmd_name"
  if is_windows
  then
    if tet -n "$win_cmd_path"
    then
      cmd_path="$win_cmd_path"
    fi
    if ! type "$cmd_path" > /dev/null 2>&1
    then
      winget install -e --id "$winget_id" 2>&1
    fi
    cmd_path="$win_cmd_path"
  elif type brew > /dev/null 2>&1
  then
    if test -n "$brew_cmd_path"
    then
      cmd_path="$brew_cmd_path"
    fi
    if ! type "$cmd_path" > /dev/null 2>&1
    then
      brew install "$brew_id"
    fi
  fi
  if $no_exec
  then
    return 0
  fi
  "$cmd_path" "$@"
)

load() {
  if ! test -r "$1"
  then
    return 0
  fi
  IFS=
  while read -r line_0e9c96b
  do
    key_07bde23="$(echo "$line_0e9c96b" | sed -E -n -e 's/^([a-zA-Z_][[:alnum:]_]*)=.*$/\1/p')"
    if test -z "$key_07bde23"
    then
      continue
    fi
    val="$(eval "echo \"\${$key_07bde23:=}\"")"
    # echo bcff3d2 "$val" >&2
    if test -n "$val"
    then
      continue
    fi
    eval "$line_0e9c96b"
  done < "$1"
  unset IFS
}

load_env() {
  if test "${APP_ENV+set}" = set
  then
    load "$SCRIPT_DIR"/.env."$APP_ENV".local
  fi
  if test "${APP_SENV+set}" != set || test "${APP_SENV}" != "test"
  then
    load "$SCRIPT_DIR"/.env.local
  fi
  if test "${APP_ENV+set}" = set
  then
    load "$SCRIPT_DIR"/.env."$APP_ENV"
  fi
  # shellcheck disable=SC1091
  load "$SCRIPT_DIR"/.env
}

get_key() (
  # Some "/bin/sh" provides `-s` option.
  # shellcheck disable=SC3045
  read -rsn1 key
  echo "$key"
)

# --------------------------------------------------------------------------

task_subcmds() ( # List subcommands.
  chdir_script
  delim=" delim_2ed1065 "
  # shellcheck disable=SC2086
  cnt="$(grep -E -h -e "^subcmd_[_[:alnum:]]+\(" $task_file_paths | sed -r -e 's/^subcmd_//' -e 's/([[:alnum:]]+)__/\1:/g' -e "s/\(\) *[{(] *(# *)?/$delim/")"
  if type delegate_tasks > /dev/null 2>&1
  then
    if delegate_tasks subcmds > /dev/null 2>&1
    then
      cnt="$(printf "%s\n%s" "$cnt" "$(delegate_tasks subcmds | sed -r -e "s/(^[^ ]+) +/\1$delim/")")"
    fi
  fi
  max_len="$(echo "$cnt" | awk '{ if (length($1) > max_len) max_len = length($1) } END { print max_len }')"
  echo "$cnt" | sort | awk -F"$delim" "{ printf \"%-${max_len}s  %s\n\", \$1, \$2 }"
)

task_tasks() { # List tasks.
  (
    delim=" delim_d3984dd "
    # shellcheck disable=SC2086
    cnt="$(grep -E -h -e "^task_[_[:alnum:]]+\(" $task_file_paths | sed -r -e 's/^task_//' -e 's/([[:alnum:]]+)__/\1:/g' -e "s/\(\) *[{(] *(# *)?/$delim/")"
    if type delegate_tasks > /dev/null 2>&1
    then
      if delegate_tasks tasks > /dev/null 2>&1
      then
        cnt="$(printf "%s\n%s" "$cnt" "$(delegate_tasks tasks | sed -r -e "s/(^[^ ]+) +/\1$delim/")")"
      fi
    fi
    max_len="$(echo "$cnt" | awk '{ if (length($1) > max_len) max_len = length($1) } END { print max_len }')"
    echo "$cnt" | sort | awk -F"$delim" "{ printf \"%-${max_len}s  %s\n\", \$1, \$2 }"
  )
}

usage() ( # Show help message.
  chdir_script
  cat <<EOF
Usage:
  $0 [options] <subcommand> [args...]
  $0 [opttions] <task[arg1,arg2,...]> [tasks...]

Options:
  -d, --directory=<dir>  Change directory before running tasks.
  -h, --help             Display this help and exit.
  -v, --verbose          Verbose mode.

Subcommands:
EOF
  task_subcmds | sed -r -e 's/^/  /'
  cat <<EOF

Tasks:
EOF
  task_tasks | sed -r -e 's/^/  /'
)

main() {
  chdir_script

  if test "${ARG0BASE+set}" = "set"
  then
    case "$ARG0BASE" in
      task-*)
        env="${ARG0BASE#task-}"
        case "$env" in
          dev|development)
            APP_ENV=development
            APP_SENV=dev
            ;;
          prd|production)
            APP_ENV=production
            APP_SENV=prd
            ;;
          *) echo "Unknown environment: $env" >&2; exit 1;;
        esac
        export APP_ENV APP_SENV
        ;;
      *)
        ;;
    esac
  fi

  task_file_paths="$(realpath "$0")"
  for task_file_path in "$SCRIPT_DIR"/task_*.sh "$SCRIPT_DIR"/task-*.sh
  do
    if ! test -r "$task_file_path"
    then
      continue
    fi
    case "$(basename "$task_file_path")" in
      task-dev.sh|task-prd.sh)
      continue
      ;;
    esac
    task_file_paths="$task_file_paths $task_file_path"
    # shellcheck disable=SC1090
    . "$task_file_path"
  done

  verbose=false
  shows_help=false
  while getopts d:hv-: OPT
  do
    if test "$OPT" = "-"
    then
      # shellcheck disable=SC2031
      OPT="${OPTARG%%=*}"
      # shellcheck disable=SC2031
      OPTARG="${OPTARG#"$OPT"}"
      OPTARG="${OPTARG#=}"
    fi
    case "$OPT" in
      d|directory) user_specified_directory="$(ensure_opt_arg "$OPT" "$OPTARG")";;
      h|help) shows_help=true;;
      v|verbose) verbose=true;;
      \?) usage; exit 2;;
      *) echo "Unexpected option: $OPT" >&2; exit 2;;
    esac
  done
  shift $((OPTIND-1))

  if $shows_help || test "${1+set}" != "set"
  then
    usage
    exit 0
  fi

  subcmd="$(echo "$1" | sed -r -e 's/:/__/g')"
  if type subcmd_"$subcmd" > /dev/null 2>&1
  then
    shift
    if alias subcmd_"$subcmd" > /dev/null 2>&1
    then
      # shellcheck disable=SC2294
      eval subcmd_"$subcmd" "$@"
      exit $?
    fi
    subcmd_"$subcmd" "$@"
    exit $?
  fi

  for task_with_args in "$@"
  do
    task_name="$task_with_args"
    args=""
    case "$task_with_args" in
      *\[*)
        task_name="${task_with_args%%\[*}"
        args="$(echo "$task_with_args" | sed -r -e 's/^.*\[//' -e 's/\]$//' -e 's/,/ /')"
        ;;
    esac
    task_name="$(echo "$task_name" | sed -r -e 's/:/__/g')"
    if ! type task_"$task_name" > /dev/null 2>&1
    then
      if type delegate_tasks > /dev/null 2>&1
      then  
        delegate_tasks "$@"
        continue
      fi
      echo "Unknown task: $task_name" >&2
      exit 1
    fi
    # shellcheck disable=SC2086
    task_"$task_name" $args
  done
}

# To make this file can be sourced to provide functions.
if test "$(basename "$0")" = "task.sh"
then
  main "$@"
fi
