#!/bin/sh
test "${guard_8d96ed9+set}" = set && return 0; guard_8d96ed9=x
set -o nounset -o errexit

if grep -q 'apfs' /etc/fstab
then
  echo cp0
fi

if ! grep -q 'hoge' /etc/fstab
then
  echo cp1
fi

sed_grep_q() {
  test -n "$(sed -n "/$1/p" /etc/fstab)"
}

if sed_grep_q 'apfs'
then
  echo cp2
fi

if ! sed_grep_q 'hoge'
then
  echo cp3
fi

