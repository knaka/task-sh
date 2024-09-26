#!/bin/sh
set -o nounset -o errexit

multiple_lines=$(cat <<EOF
This is a
multiple line
string.
EOF
)

echo "$multiple_lines"
