# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_737f6db-false}" && return 0; sourced_737f6db=true

oct_dump() {
  if test $# -eq 0
  then
    cat
  else
    printf "%s" "$@"
  fi \
  | od -A n -t o1 -v \
  | xargs printf "%s "
}

oct_restore() {
  if test $# -eq 0
  then
    cat
  else
    printf "%s" "$@"
  fi \
  | xargs printf '\\\\0%s\n' \
  | xargs printf '%b'
}

hex_dump() {
  if test $# -eq 0
  then
    cat
  else
    printf "%s" "$@"
  fi \
  | od -A n -t x1 -v \
  | xargs printf "%s "
}

hex_restore() {
  # shellcheck disable=SC2016
  if test $# -eq 0
  then
    cat
  else
    printf "%s" "$@"
  fi \
  | xargs printf "%s\n" \
  | (
    set -- awk
    if command -v mawk >/dev/null 2>&1
    then
      set -- mawk
    elif command -v gawk >/dev/null 2>&1
    then
      set -- gawk --non-decimal-data
    fi
    "$@" '{ printf("%c", int("0x" $1)) }'
  )
}
