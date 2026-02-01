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
  awk "BEGIN { printf \"$(
    if test $# -eq 0
    then
      cat
    else
      printf "%s" "$@"
    fi \
    | xargs printf "\\\x%s"
  )\" }"
}
