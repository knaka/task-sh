# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_9acb992-}" = true && return 0; sourced_9acb992=true

. ./task.sh

cleanup_session_env() {
  if test -r "$PROJECT_DIR"/.env.session
  then
    rm -f "$PROJECT_DIR"/.env.session
  fi
}

# Checks if the key is a session entry (.i.e. the key is in .env.session or not).
is_session_entry_da4efd1() (
  key="$1"
  if ! test -r "$PROJECT_DIR"/.env.session
  then
    return 1
  fi
  grep -q -E "^$key=" "$PROJECT_DIR"/.env.session
)

# Deletes a session entry from .env.session.
delete_session_entry_78b4000() (
  if ! test -r "$PROJECT_DIR"/.env.session
  then
    return 0
  fi
  local key="$1"
  sed -i '' -E -e "/^$key=/d" "$PROJECT_DIR"/.env.session
)

# # Unsets a session entry.
# unset_session_env_entry() {
#   local key="$1"
#   if is_session_entry_da4efd1 "$key"
#   then
#     delete_session_entry_78b4000 "$key"
#     eval "unset $key"
#   fi
# }

# Adds a dynamic entry to .env.session.
add_session_env_entry_097e405() (
  local key="$1"
  local val="$2"
  delete_session_entry_78b4000 "$key"
  echo "$key=$val" >>"$PROJECT_DIR"/.env.session
)

# Sets a dynamic entry.
set_session_env_entry() {
  local key val
  while test $# -gt 0
  do
    key="$1"
    val="$2"
    shift 2
    if eval "test ! \"\${$key+set}\" = set"
    then
      add_session_env_entry_097e405 "$key" "$val"
      # Just define the variable without exporting it. User can export it manually.
      # eval "$key=$val"
      # eval "export $key=$val"
    fi
  done
}
