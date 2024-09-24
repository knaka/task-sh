#!/bin/sh
set -o nounset -o errexit

if test -r "$1"
then
  echo "File $1 already exists. Only touching it." >&2
  touch "$1"
  exit 0
fi

cat <<EOF > "$1"
#!/bin/sh
set -o nounset -o errexit
EOF
