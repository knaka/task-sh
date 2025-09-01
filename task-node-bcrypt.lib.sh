# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_880b3c0-}" = true && return 0; sourced_880b3c0=true

. ./task-node.lib.sh

# [password] Generate a bcrypt hash for the given password.
subcmd_bcrypt__hash() {
  local password="$1"
  local salt_rounds=10
  subcmd_npm__ensure bcryptjs
  subcmd_node -e "console.log(require('bcryptjs').hashSync('${password}', ${salt_rounds}))"
}

# [password hash] Verify the password against the hash.
subcmd_bcrypt__verify() {
  local password="$1"
  local hash="${2:-10}"
  case "$hash" in
    (\$*) ;;
    (*)
      echo "Invalid hash. The hash should start with a dollar sign." >&2
      return 1
      ;;
  esac
  subcmd_npm__ensure bcryptjs
  if subcmd_node -e "process.exit(require('bcryptjs').compareSync('${password}', '${hash}')? 0: 1)"
  then
    echo "The password verification succeeded." >&2
    return 0
  fi
  echo "The password verification failed." >&2
  return 1
}
