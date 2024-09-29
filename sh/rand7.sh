#!/bin/sh
set -o nounset -o errexit

. "$(dirname "$0")"/task.sh

if test -r /dev/urandom
then
  seed=$(od -An -N4 -tu4 < /dev/urandom | tr -d ' ')
elif is_bsd
then
  seed=$(date +%s)
else
  seed=$(date +%N)
fi
# 0.0 <= rand() < 1.0
# 268435456 = 0xFFFFFFF + 1.
# Hexadecimal integer literal is available only on GAwk.
awk -v seed="$seed" 'BEGIN { srand(seed); printf "%07x\n", int(rand() * 268435456) }'
