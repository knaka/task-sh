#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_681a654-false}" && return 0; sourced_681a654=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./task-yq.lib.sh
cd "$1"; shift 2

yaml2json_help() {
  cat <<EOF
Convert YAML to JSON.

Usage: ${0##*/} [options] [file...]

Options:
  -h, --help
    Show this help message and exit.
  -i, --inplace
    Convert to the JSON file in place.
  -I, --inplace-existing
    Convert to the JSON file in place only if it exists.
EOF
}

yaml2json() {
  local inplace=false
  local only_if_existing=false
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
        yaml2json_help
        exit 0
        ;;
      (i|inplace)
        inplace=true
        ;;
      (I|inplace-existing)
        inplace=true
        only_if_existing=true
        ;;
      (\?) exit 1;;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  if "$inplace"
  then
    if test $# -eq 0
    then
      echo "No files specified for inplace conversion" >&2
      exit 1
    fi
    local file
    local json_file
    for file in "$@"
    do
      if test ! -r "$file"
      then
        echo "File not found: $file" >&2
        exit 1
      fi
      json_file="${file%.*}.json"
      if "$only_if_existing" && ! test -r "$json_file"
      then
        echo "File not found: $json_file. Skikpping." >&2
        continue
      fi
      if test -r "$json_file"
      then
        chmod +w "$json_file"
      fi
      subcmd_yq -o json "$file" >"$json_file"
      chmod -w "$json_file"
    done
  else
    subcmd_yq -o json "$@"
  fi
}

case "${0##*/}" in
  (yaml2json.sh|yaml2json)
    set -o nounset -o errexit
    yaml2json "$@"
    ;;
esac
