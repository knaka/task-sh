#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_b425ed1-false}" && return 0; sourced_b425ed1=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./task-mlr.lib.sh
cd "$1"; shift 2

emlr_help() {
  cat <<EOF
Format Delimiter-Separated Values files using the MLR (Miller) "put" command. If the input file has a ".cmt.csv" extension, an embedded script in its comment lines prefixed with "# +MLR: ..." or "# +MILLER: ..." will be used. Otherwise, if a script file named "foo.mlr" exists for "foo.csv", it will be used instead.

Usage: ${0##*/} [options] [file...]

Options:
  -h, --help
    Display this help message and exit.
  -i, --inplace
    Modify the DSV file in place.
EOF
}

emlr() {
  local inplace=false
  OPTIND=1; while getopts _hiI-: OPT
  do
    if test "$OPT" = "-"
    then
      OPT="${OPTARG%%=*}"
      # shellcheck disable=SC2030
      OPTARG="${OPTARG#"$OPT"}"
      OPTARG="${OPTARG#=}"
    fi
    case "$OPT" in
      (h|help)
        emlr_help
        exit 0
        ;;
      (i|inplace)
        inplace=true
        ;;
      (\?) exit 1;;
      (*)
        echo "Unexpected option: $OPT" >&2;
        emlr_help
        exit 1
        ;;
    esac
  done
  shift $((OPTIND-1))

  local file_path
  local file_ext
  local script_file_path
  for file_path in "$@"
  do
    if ! test -f "$file_path"
    then
      echo "File not found: $file_path" >&2
      exit 1
    fi
    case "$file_path" in
      (*.cmt.csv|*.cmt.tsv)
        file_ext="${file_path##*.}"
        script_file_path="$TEMP_DIR"/script.mlr
        sed -n -e 's/^# MLR: \(.*\)/\1/p' -e 's/^# MILLER: \(.*\)/\1/p' "$file_path" >"$script_file_path"
        if ! test -s "$script_file_path"
        then
          echo "No MLR script found in $file_path." >&2
          continue
        fi
        ;;
      (*.csv|*.tsv)
        file_ext="${file_path##*.}"
        script_file_path="$file_path".mlr
        if ! test -r "$script_file_path"
        then
          echo "No MLR script found for $file_path." >&2
          continue
        fi
        ;;
      (*)
        echo "Unsupported file type: $file_path" >&2
        exit 1
        ;;
    esac
    # Global options for Miller
    # `--lazy-quotes` to avoid error double quotes in comments
    set -- --i"$file_ext" --o"$file_ext" --pass-comments
    if "$inplace"
    then
      set -- "$@" -I
    fi
    cat "$script_file_path" >&2
    # Subcommand and its arguments
    set -- "$@" put -f "$script_file_path" "$file_path"
    mlr "$@"
  done
}

case "${0##*/}" in
  (emlr.sh|emlr)
    set -o nounset -o errexit
    emlr "$@"
    ;;
esac
