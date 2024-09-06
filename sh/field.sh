#!/bin/sh
set -o nounset -o errexit

# Print 1-indexed n-th field of input lines.
awk "{print \$${1}}"
