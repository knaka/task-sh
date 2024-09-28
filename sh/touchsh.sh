#!/bin/sh
set -o nounset -o errexit

if test -r "$1"
then
  echo "File $1 already exists. Only touching it." >&2
  touch "$1"
  exit 0
fi

unique_id="$(sh "$(dirname "$0")"/rand7.sh)"
cat <<EOF > "$1"
#!/bin/sh
set -o nounset -o errexit

test "\${guard_${unique_id}+set}" = set && return 0; guard_${unique_id}=-
EOF
