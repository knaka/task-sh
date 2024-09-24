#!/bin/sh
set -o nounset -o errexit

exec diff -uNr "$@"
