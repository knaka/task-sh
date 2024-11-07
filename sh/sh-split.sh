#!/bin/sh
test "${guard_a1f7080+set}" = set && return 0; guard_a1f7080=x
set -o nounset -o errexit

s="foo:bar bar:baz:hoge:fuga"

# You can limit the number of fields.
IFS=: read -r a _ _ d <<EOF
$s
EOF
echo a: "$a"
echo d: "$d"

echo

IFS=: read -r a _ _ d <<EOF
$(echo "$s" | tr '[:lower:]' '[:upper:]')
EOF
echo a: "$a"
echo d: "$d"

echo

# Array rather than tuple.
IFS=:
# shellcheck disable=SC2086
set -- $s
echo a: "$1"
echo b: "$2"
unset IFS
printf "%s\n" "$@" | tr '[:lower:]' '[:upper:]' | paste -sd : -

echo

# String-jointing.
cat <<EOF | paste -sd : -
foo
bar
baz
EOF

# POSIX shell does not support process substitution.
longest_device=
while IFS=' ' read -r device _ _ _ _ _ _ _ mntpnt
do
  echo "Device: $device, Mount point: $mntpnt"
  if test "${#device}" -gt "${#longest_device}"
  then
    longest_device=$device
  fi
done <<EOF
$(
  df | tail -n +2
)
EOF

echo "Longest device: $longest_device"
