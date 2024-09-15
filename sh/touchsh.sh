#!/bin/sh
set -o nounset -o errexit
cat <<EOF > "$1"
#!/bin/sh
set -o nounset -o errexit
EOF
