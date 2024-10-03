#!/bin/sh

test "${guard_9f33a95+set}" = set && return 0; guard_9f33a95=-

ls_with_option() {
  ls -l
}

alias ls-with-option='ls -l'
