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

# Since POSIX shell does not support process substitution, you can use command substitution within a here document instead.
longest_device0=
while read -r device _ _ _ _ _ _ _ mntpnt
do
  echo "Device: $device, Mount point: $mntpnt" >&2
  if test "${#device}" -gt "${#longest_device0}"
  then
    longest_device0=$device
  fi
done <<EOF
$(
  df | tail -n +2
)
EOF

echo "Longest device: $longest_device0"

# "Functional" way would be better.
exec 3>&2
longest_device=$(
  df | tail -n +2 | while read -r device _ _ _ _ _ _ _ mntpnt
  do
    echo "Device: $device, Mount point: $mntpnt" >&3
    echo "${#device}" "$device"
  done | sort -nr | head -n 1 | (
    read -r _ longest_device
    echo "$longest_device"
  )
)
exec 3>&-

echo "Longest device: $longest_device"
