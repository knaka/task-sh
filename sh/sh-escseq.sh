#!/bin/sh
set -o nounset -o errexit

test "${guard_7d86474+set}" = set && return 0; guard_7d86474=x

. ./task.sh

# Underlined text with escape sequences.
echo "The $(underline "word") is underlined!"

my_prompt_usage() {
  echo
  echo "$(emph "C")lear screen."
  echo "E$(emph "X")it."
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
