#!/bin/sh
set -o nounset -o errexit

char="-"
count=76

case $# in
  1)
    count=$1
    ;;
  2)
    char=$1
    count=$2
    ;;
esac

printf "%${count}s\n" "" | tr ' ' "$char"
