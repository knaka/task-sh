#!/bin/sh
set -o nounset -o errexit

multiple_lines=$(cat <<EOF
This is a
multiple line
string.
EOF
)

printf "116630c %s 9bac7ae" "$multiple_lines"

