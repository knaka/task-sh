#!/bin/sh
set -o nounset -o errexit

test "${guard_7d86474+set}" = set && return 0; guard_7d86474=x

. ./task.sh

# Underlined text with escape sequences.
echo "The $(underline "word") is underlined!"

menu_item() (
  if ! echo "$1" | grep -q -E -e '&'
  then
    echo "$1"
    return
  fi
  pre="$(printf "%s" "$1" | sed -E -e 's/&.*//')"
  ch="$(printf "%s" "$1" | sed -E -e 's/.*&(.).*/\1/')"
  post="$(printf "%s" "$1" | sed -E -e 's/.*&.//')"
  echo "$pre$(emph "$ch")$post"
)

my_prompt_usage() {
  echo
  menu_item "&Clear"
  menu_item "E&xit"
}

my_prompt() {
  while true
  do
    my_prompt_usage
    case "$(get_key)" in
      c) clear ;;
      x) break ;;
      *) ;;
    esac
  done
}

my_prompt
