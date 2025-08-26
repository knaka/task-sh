#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_102a099-false}" && return 0; sourced_102a099=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./task.sh
cd "$1"; shift 2

init_temp_dir

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
        exit 1
        ;;
    esac
  done
  shift $((OPTIND-1))

  local target_url="$1"
  set -- wget --spider -R css,js -r --no-parent
  if test -n "$excluded_directories"
  then
    local target_dir="$(echo "$target_url" | sed -Ee 's@http.?://[^/]*@@')"
    local saved_ifs="$IFS"; IFS=","
    local excluded_directory
    for excluded_directory in $excluded_directories
    do
      case "$excluded_directory" in
        ("$target_dir/"*) ;;
        (*)
          echo "Excluded directory \"$excluded_directory\" must start with \"$target_dir\"." >&2
          exit 1
          ;;
      esac
    done
    IFS="$saved_ifs"
    set -- "$@" --exclude-directories="$excluded_directories"
  fi
  set -- "$@" "$target_url"
  echo "Running: $*" >&2
  local temp_file_path="$TEMP_DIR/urlrec.log"
  LANG=C "$@" 2>&1 | tee "$temp_file_path"
  # Extract only retrieved URLs from wget(1) log
  # 1. Extract URLs from lines like "--2024-01-01 12:00:00-- https://example.com/page.html"
  #    - s/^.* //: remove everything up to the last space (leaving just the URL)
  #    - h: store the URL in hold space for later use
  # 2. Find status lines that contain "-- retrieving."
  #    - g: get the URL from hold space back into pattern space
  #    - p: print the URL
  grep -e ' http' -e '-- retrieving' "$temp_file_path" \
    | sed -n -e '/^--.* http/ {s/^.* //; h;}' -e '/-- retrieving\./ {g; p;}'
}

case "${0##*/}" in
  (urlrec.sh|urlrec)
    set -o nounset -o errexit
    urlrec "$@"
    ;;
esac
