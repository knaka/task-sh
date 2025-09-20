# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_737f6db-false}" && return 0; sourced_737f6db=true

# ==========================================================================
#region Binary - text encoding/decoding

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

#endregion
