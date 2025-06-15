#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_102a099-false}" && return 0; sourced_102a099=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./task.sh
cd "$1"; shift 2

urlrec() {
  local excluded_directories=
  OPTIND=1; while getopts _x:-: OPT
  do
    if test "$OPT" = "-"
    then
      OPT="${OPTARG%%=*}"
      # shellcheck disable=SC2030
      OPTARG="${OPTARG#"$OPT"}"
      OPTARG="${OPTARG#=}"
    fi
    case "$OPT" in
      (x|exclude-directories)
        excluded_directories="$OPTARG"
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


  local target_url="$1"
  set -- wget --spider -R css,js -r --no-parent
  if test -n "$excluded_directories"
  then
    set -- "$@" --exclude-directories="$excluded_directories"
  fi
  set -- "$@" "$target_url"
  echo "Running: $*" >&2
  local temp_file_path="$TEMP_DIR/urlrec.log"
  LANG=C "$@" 2>&1 | tee "$temp_file_path"
  grep -e ' http' -e '-- retrieving' "$temp_file_path" \
  | sed -n -e '/^--.* http/ {s/^.* //; h;}' -e '/-- retrieving\./ {g; p;}' 
}

case "${0##*/}" in
  (urlrec.sh|urlrec)
    set -o nounset -o errexit
    urlrec "$@"
    ;;
esac
