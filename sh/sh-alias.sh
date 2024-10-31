#!/bin/sh
set -o nounset -o errexit

test "${guard_b657fd4+set}" = set && return 0; guard_b657fd4=x

# Aliases are expanded when a function is defined, not when it is executed.
foo() {
  . ./sh-alias.lib.sh
  # ls_with_option /
  alias ls-with-option='ls -l'
  # ls-with-option / # Error
}

# foo

alias ls-long='ls -l'
# ls-long # OK
name=ls-long
# "$name" / # Error

eval "$name" /