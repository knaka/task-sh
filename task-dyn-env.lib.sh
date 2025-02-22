# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_9acb992-}" = true && return 0; sourced_9acb992=true

. ./task.sh

cleanup_dynamic_entries() {
  if test -r "$PROJECT_DIR"/.env.dynamic
  then
    rm -f "$PROJECT_DIR"/.env.dynamic
  fi
}

# Checks if the key is a dynamic entry (.i.e. the key is in .env.dynamic or not).
is_dynamic_entry_da4efd1() (
  key="$1"
  if ! test -r .env.dynamic
  then
    return 1
  fi
  grep -q -E "^$key=" .env.dynamic
)

# Deletes a dynamic entry from .env.dynamic.
delete_dynamic_entry_78b4000() (
  if ! test -r .env.dynamic
  then
    return 0
  fi
  key="$1"
  sed -i '' -E -e "/^$key=/d" .env.dynamic
)

# Unsets a dynamic entry.
unset_dynamic_entry() {
  key_4cee18d="$1"
  if is_dynamic_entry_da4efd1 "$key_4cee18d"
  then
    delete_dynamic_entry_78b4000 "$key_4cee18d"
    eval "unset $key_4cee18d"
  fi
}

# Adds a dynamic entry to .env.dynamic.
add_dynamic_entry_097e405() (
  key="$1"
  val="$2"
  delete_dynamic_entry_78b4000 "$key"
  echo "$key=$val" >>.env.dynamic
)

# Sets a dynamic entry.
set_dynamic_entry() {
  key_67d9a4f="$1"
  val_5d77cea="$2"
  if eval "test ! \"\${$key_67d9a4f+set}\" = set"
  then
    add_dynamic_entry_097e405 "$key_67d9a4f" "$val_5d77cea"
    eval "export $key_67d9a4f=$val_5d77cea"
  fi
}
