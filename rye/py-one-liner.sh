#!/bin/sh
set -o nounset -o errexit

test "${guard_4ffe86e+set}" = set && return 0; guard_4ffe86e=x

no_indent_script="$(cat <<'EOF'
print("Hello, World1!")
print("Hello, World2!")
[print(i) for i in range(10)]
EOF
)"

no_indent_script="$(echo "$no_indent_script" | tr '\n' ';')"
sh ./task python -c "$no_indent_script" "$@"
