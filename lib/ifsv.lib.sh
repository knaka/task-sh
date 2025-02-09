# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_89a99a9-}" = true && return 0; sourced_89a99a9=true

. ./task.sh

# --------------------------------------------------------------------------
# IFS-separated value functions.
# --------------------------------------------------------------------------

# Head of IFSV.
ifsv_head() {
  test $# -eq 0 && return 1
  # shellcheck disable=SC2086
  set -- $1
  printf "%s" "$1"
}

# Tail of IFSV.
ifsv_tail() {
  test $# -eq 0 && return 1
  # shellcheck disable=SC2086
  set -- $1
  shift
  local item
  for item in "$@"
  do
    printf "%s%s" "$item" "$IFS"
  done
}

ifsv_length() {
  # shellcheck disable=SC2086
  set -- $1
  echo "$#"
}

ifsv_empty() {
  test -z "$1"
}

# Join IFS-separated values with a delimiter.
ifsv_join() {
  local out_delim="$2"
  # shellcheck disable=SC2086
  set -- $1
  local delim=
  local arg=
  for arg in "$@"
  do
    printf "%s%s" "$delim" "$arg"
    delim="$out_delim"
  done
}

# Get an item at a specified index.
ifsv_at() {
  local i=0
  local item
  for item in $1
  do
    if test "$i" = "$2"
    then
      if test "${3+set}" = set
      then
        printf "%s%s" "$3" "$IFS"
      else
        printf "%s" "$item"
        return
      fi
    else
      if test "${3+set}" = set
      then
        printf "%s%s" "$item" "$IFS"
      fi
    fi
    i=$((i + 1))
  done
}

# Map IFS-separated values with a command. If the command contains "_", then it is replaced with the item.
ifsv_map() {
  local arr="$1"
  shift
  local should_replace=false
  local arg
  for arg in "$@"
  do
    if test "$arg" = "_" || test "$arg" = "it"
    then
      should_replace=true
    fi
  done
  local i=0
  local item
  for item in $arr
  do
    if $should_replace
    then
      (
        for arg in "$@"
        do
          if test "$arg" = "_"
          then
            arg="$item"
          fi
          set -- "$@" "$arg"
          shift
        done
        printf "%s%s" "$("$@")" "$IFS"
      )
    else
      printf "%s%s" "$("$@" "$item")" "$IFS"
    fi
    i=$((i + 1))
  done
}

# Filter IFS-separated values with a command. If the command contains "_", then it is replaced with the item.
ifsv_filter() {
  local arr="$1"
  shift
  local should_replace=false
  local arg
  for arg in "$@"
  do
    if test "$arg" = "_"
    then
      should_replace=true
    fi
  done
  local item
  for item in $arr
  do
    if $should_replace
    then
      if ! (
        for arg in "$@"
        do
          if test "$arg" = "_"
          then
            arg="$item"
          fi
          set -- "$@" "$arg"
          shift
        done
        "$@"
      )
      then
        continue
      fi
    elif ! "$@" "$item"
    then
      continue
    fi
    printf "%s%s" "$item" "$IFS"
  done
}

# Reduce IFS-separated values with a function. If the function contains "_", then it is replaced with the accumulator and the item.
ifsv_reduce() {
  local arr="$1"
  shift
  local acc="$1"
  shift
  local has_place_holder=false
  local arg
  for arg in "$@"
  do
    if test "$arg" = "_"
    then
      has_place_holder=true
    fi
  done
  local item
  for item in $arr
  do
    if $has_place_holder
    then
      acc="$(
        first_place_holder=true
        for arg2 in "$@"
        do
          if test "$arg2" = "_"
          then
            if $first_place_holder
            then
              arg2="$acc"
              first_place_holder=false
            else
              arg2="$item"
            fi
          fi
          set -- "$@" "$arg2"
          shift
        done
        "$@"
      )"
    else
      acc="$("$@" "$acc" "$item")"
    fi
  done
  printf "%s" "$acc"
}

# Check if an IFS-separated value contains a specified item.
ifsv_contains() {
  local arr="$1"
  local target="$2"
  local item
  for item in $arr
  do
    if test "$item" = "$target"
    then
      return
    fi
  done
  return 1
}

# Sort IFS-separated values.
ifsv_sort() {
  local arr="$1"
  if test -z "$arr"
  then
    return
  fi
  shift
  local vers
  # shellcheck disable=SC2086
  vers="$(
    printf "%s\n" $arr \
    | if test "$#" -eq 0
    then
      sort
    else
      "$@"
    fi
  )"
  push_ifs
  set_ifs_newline
  # shellcheck disable=SC2086
  set -- $vers
  pop_ifs
  local item
  for item in "$@"
  do
    printf "%s%s" "$item" "$IFS"
  done
}

# --------------------------------------------------------------------------
# Associative array functions. It is represented as propty list.
# --------------------------------------------------------------------------

# Get a value from an associative array implemented as a property list.
ifsv_get() {
  local plist="$1"
  local target_key="$2"
  local key=
  local i=0
  for item in $plist
  do
    if test $((i % 2)) -eq 0
    then
      key="$item"
    else
      if test "$key" = "$target_key"
      then
        printf "%s" "$item"
        return
      fi
    fi
    i=$((i + 1))
  done
  return 1
}

# Keys of an associative array implemented as a property list.
ifsv_keys() {
  local plist="$1"
  local i=0
  local item
  for item in $plist
  do
    if test $((i % 2)) -eq 0
    then
      printf "%s%s" "$item" "$IFS"
    fi
    i=$((i + 1))
  done
}

# Values of an associative array implemented as a property list.
ifsv_values() {
  local plist="$1"
  local i=0
  local item
  for item in $plist
  do
    if test $((i % 2)) -eq 1
    then
      printf "%s%s" "$item" "$IFS"
    fi
    i=$((i + 1))
  done
}

# Put a value in an associative array implemented as a property list.
ifsv_put() {
  local plist="$1"
  local target_key="$2"
  local value="$3"
  local found=false
  local key=
  local i=0
  local item
  for item in $plist
  do
    if test $((i % 2)) -eq 0
    then
      key="$item"
    else
      if test "$key" = "$target_key"
      then
        found=true
        printf "%s%s%s%s" "$target_key" "$IFS" "$value" "$IFS"
      else
        printf "%s%s%s%s" "$key" "$IFS" "$item" "$IFS"
      fi
    fi
    i=$((i + 1))
  done
  if ! "$found"
  then
    printf "%s%s%s%s" "$target_key" "$IFS" "$value" "$IFS"
  fi
}
