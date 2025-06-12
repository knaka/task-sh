#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_569237b-false}" && return 0; sourced_569237b=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./task.sh
cd "$1"; shift 2

ed() {
  local should_block=false
  OPTIND=1; while getopts b-: OPT
  do
    if test "$OPT" = "-"
    then
      OPT="${OPTARG%%=*}"
      # shellcheck disable=SC2030
      OPTARG="${OPTARG#"$OPT"}"
      OPTARG="${OPTARG#=}"
    fi
    case "$OPT" in
      (b|block) should_block=true;;
      (\?) exit 1;;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  # Prompt for confirmation
  # Resolve all symlinks, as the links amongh Markdown files not to be broken
  local arg
  for arg in "$@"
  do
    if test -e "$arg"
    then
      arg="$(realpath "$arg")"
      if test -d "$arg"
      then
        printf "%s is a directory. " "$arg" >&2
        if ! prompt_confirm "Open?" "n" >&2
        then
          exit 0
        fi
      elif test -f "$arg"
      then
        arg="$(realpath "$arg")"
      else
        exit 1
      fi
    else
      # Resolve only directory symlinks, as the file does not exist
      local arg_dir="$(realpath "$(dirname "$arg")")"
      local arg_base="$(basename "$arg")"
      arg="$arg_dir/$arg_base"
      if ! test -e "$arg"
      then
        printf "File %s does not exist. " "$arg" >&2
        if ! prompt_confirm "Create?" "n" >&2
        then
          exit 0
        fi
        mkdir -p "$arg_dir"
        touch "$arg"
      fi
    fi
    shift
    set -- "$@" "$arg"
  done

  # VSCode
  if command -v code >/dev/null 2>&1
  then
    if $should_block
    then
      set -- --wait "$@"
    fi
    set -- code "$@"
  fi
  finalize
  exec "$@"
}

if test "${0##*/}" = "ed.sh"
then
  set -o nounset -o errexit
  ed "$@"
fi
