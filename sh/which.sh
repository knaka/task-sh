#!/bin/sh
set -o errexit -o nounset

exec which "$@"

