#!/bin/sh
set -o nounset -o errexit

test "${guard_a8ac234+set}" = set && return 0; guard_a8ac234=x

. ./task.sh

usage_prompt() {
  echo
  menu_item "&Clear"
  menu_item "E&xit"
}

prompt() {
  usage_prompt
  while true
  do
    case "$(get_key)" in
      c) clear ;;
      x) break ;;
      *) ;;
    esac
  done
}

task_cli() {
  read -e s
  echo d: $s  
}
