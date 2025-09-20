# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_1f65452-false}" && return 0; sourced_1f65452=true

# Encode positional parameters into a string that can be passed to `eval` to restore the positional parameters.
#
# Example:
#   local eval_args="$(make_eval_args "$@")"
#   set --
#   eval "set -- $eval_args"
make_eval_args() {
  local arg
  local first
  # Quotation character inside parameter expansion confuses static analysis tools.
  local quote="'"
  for arg in "$@"
  do
    printf "'"
    until test "$arg" = "${arg#*"$quote"}"
    do
      first="${arg%%"$quote"*}"
      arg="${arg#*"$quote"}"
      printf "%s'\"'\"'" "$first"
    done
    printf "%s' " "$arg"
  done
}

# Memoize the output of a series of commands. If you would like to nest, use subprocess function or `memoize` function instead.
#
# Usage:
#   foo() {
#     begin_memoize 8701441 "$@" || return 0
#
#     echo hello
#     sleep 3 # Takes long time.
#     echo world
#
#     end_memoize
#   }

# Current cache file path for memoization.
cache_file_path_cb3727b=

begin_memoize() {
  cache_file_path_cb3727b="$TEMP_DIR"/cache-"$(echo "$@" | sha1sum | cut -d' ' -f1)"
  if test -r "$cache_file_path_cb3727b"
  then
    cat "$cache_file_path_cb3727b"
    return 1
  fi
  exec 9>&1
  exec >"$cache_file_path_cb3727b"
}

end_memoize() {
  exec 1>&9
  exec 9>&-
  cat "$cache_file_path_cb3727b"
}
