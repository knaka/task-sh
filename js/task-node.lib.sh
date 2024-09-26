#!/bin/sh
set -o errexit -o nounset

set_dir_sync_ignored "$(dirname "$0")"/node_modules
