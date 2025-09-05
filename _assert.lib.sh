# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_58df3d6-}" = true && return 0; sourced_58df3d6=true

# Assertion functions

assert_eq() {
  test "$1" = "$2" && return 0
  printf "Equality assertion failed%s\n" "${3:+ ($3)}"
  printf "  LHS: %s\n" "$1"
  printf "  RHS: %s\n" "$2"
  return 1
}

assert_neq() {
  test "$1" = "$2" || return 0
  printf "Inequality assertion failed%s\n" "${3:+ ($3)}"
  printf "  LHS: %s\n" "$1"
  printf "  RHS: %s\n" "$2"
  return 1
}

assert_true() {
  "$@" && return 0
  printf "Failed: \"%s\" is not true\n" "$*"
  return 1
}

assert_false() {
  "$@" || return 0
  printf "Failed: \"%s\" is not false\n" "$*"
  return 1
}

# assert_match <expected> <actual>
assert_match() {
  echo "$2" | grep -E -q "$1" && return 0
  printf "Failed: \"%s\" does not match \"%s\"%s\n" "$2" "$1" "${3:+ ($3)}"
  return 1
}
