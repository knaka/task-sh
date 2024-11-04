#!/bin/sh
set -o nounset -o errexit

test "${guard_429c89f+set}" = set && return 0; guard_429c89f=x

. ./task.sh
. ./assert.lib.sh

# First, check that errexit is on.
assert_match "^errexit[[:space:]]+on$" "$(set -o | grep -E '^errexit\b')"

# Fails to restore the flags if it was not saved.
assert_false restore_shell_flags

# Save the flags.
backup_shell_flags
assert_match '^set -o errexit$' "$shell_flags_c225b8f"

# Fails to save the flags if it was already saved. Does not nest.
assert_false backup_shell_flags

# Turn it off.
set +o errexit
assert_match "^errexit[[:space:]]+off$" "$(set -o | grep -E '^errexit\b')"

# Restore the flags.
restore_shell_flags
assert_false test "${shell_flags_c225b8f+set}" = set
