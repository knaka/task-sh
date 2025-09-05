# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_ce1c863-}" = true && return 0; sourced_ce1c863=true

. ./yq.lib.sh
. ./sqldef.lib.sh
. ./node.lib.sh
. ./cloudflare.lib.sh

db_schema_path_d4253e5="$TASKS_DIR/schema.sql"

set_db_schema_path() {
  db_schema_path_d4253e5="$1"
}

db_seed_path_540ec19="$TASKS_DIR/seed.sql"

set_db_seed_path() {
  db_seed_path_540ec19="$1"
}

# --------------------------------------------------------------------------
# Get values from Wrangler configuration file
# --------------------------------------------------------------------------

# [index = 0] Show the binding name of the D1 database configured in the configuration file.
subcmd_d1__binding() {
  local index="${1:-0}"
  yq --exit-status eval ".env.production.d1_databases.$index.binding // .d1_databases.$index.binding" "$wrangler_toml_path"
}

# [index = 0] Show the binding name of the preview D1 database configured in the configuration file.
subcmd_d1__prev__binding() {
  local index="${1:-0}"
  yq --exit-status eval ".env.preview.d1_databases.$index.binding // .d1_databases.$index.binding" "$wrangler_toml_path"
}

# [index = 0] Show the name of the D1 database configured in the configuration file.
subcmd_d1__name() {
  local index="${1:-0}"
  yq --exit-status eval ".env.production.d1_databases.$index.database_name // .d1_databases.$index.database_name" "$wrangler_toml_path"
}

# [index = 0] Show the name of the preview D1 database configured in the configuration file.
subcmd_d1__prev__name() {
  local index="${1:-0}"
  yq --exit-status eval ".env.preview.d1_databases.$index.database_name // .d1_databases.$index.database_name" "$wrangler_toml_path"
}

# [index = 0] Show the ID of the D1 database configured in the configuration file.
subcmd_d1__id() {
  local index="${1:-0}"
  yq --exit-status eval ".env.production.d1_databases.$index.database_id // .d1_databases.$index.database_id" "$wrangler_toml_path"
}

# [index = 0] Show the ID of the preview D1 database configured in the configuration file.
subcmd_d1__prev__id() {
  local index="${1:-0}"
  yq --exit-status eval ".env.preview.d1_databases.$index.database_id // .d1_databases.$index.database_id" "$wrangler_toml_path"
}

# --------------------------------------------------------------------------
# Tasks for Cloudflare's global D1 services
# --------------------------------------------------------------------------

# List all D1 databases.
subcmd_d1__list() {
  wrangler d1 list
}

# Show the information for the D1 database.
subcmd_d1__info() {
  wrangler d1 info --json "$(subcmd_d1__name)"
}

# Show the information for the preview D1 database.
subcmd_d1__prev__info() {
  wrangler d1 info --json --env preview "$(subcmd_d1__prev__name)"
}

# Create a new D1 database. This must be executed only once during the project lifecycle.
subcmd_d1__create() {
  wrangler d1 create "$@"
}

# Create a new preview D1 database. This must be executed only once during the project lifecycle.
subcmd_d1__prev__create() {
  wrangler d1 create --env preview "$@"
}

# --------------------------------------------------------------------------
# Execute SQL commands
# --------------------------------------------------------------------------

# Execute SQL command in the local D1 database.
subcmd_d1__local__exec() {
  wrangler d1 execute --local "$(subcmd_d1__name)" "$@"
}

# Execute SQL command in the D1 database.
subcmd_d1__exec() {
  wrangler d1 execute --remote "$(subcmd_d1__name)" "$@"
}

# Execute SQL command in the preview D1 database.
subcmd_d1__prev__exec() {
  wrangler d1 --env preview execute --remote "$(subcmd_d1__prev__name)" "$@"
}

# --------------------------------------------------------------------------
# Dump the database
# --------------------------------------------------------------------------

# Dump the database.
d1_dump() {
  local output_file_path="$TEMP_DIR"/dump.sql
  wrangler d1 export --output="$output_file_path" "$@"
  cat "$output_file_path"
} 

# Dump the local database.
subcmd_d1__local__dump() {
  d1_dump --local "$(subcmd_d1__name)"
}

# Dump the database.
subcmd_d1__dump() {
  d1_dump --remote "$(subcmd_d1__name)"
}

# Dump the preview database.
subcmd_d1__prev__dump() {
  d1_dump --env preview --remote "$(subcmd_d1__prev__name)"
}

# --------------------------------------------------------------------------
# Get the schema of the database
# --------------------------------------------------------------------------

d1_schema() { # Export the schema from the D1 database.
  local schema_file_path="$TEMP_DIR"/schema.sql 
  wrangler d1 export --no-data "$@" --output="$schema_file_path" 1>&2
  cat "$schema_file_path"
}

# Export the schema from the local D1 database.
subcmd_d1__local__schema() {
  d1_schema --local "$(subcmd_d1__name)"
}

# Export the schema from the D1 database.
subcmd_d1__schema() {
  d1_schema --remote "$(subcmd_d1__name)"
}

# Export the schema from the preview D1 database.
subcmd_d1__prev__schema() {
  d1_schema --env preview --remote "$(subcmd_d1__prev__name)"
}

# --------------------------------------------------------------------------
# Seed the database
# --------------------------------------------------------------------------

# Seed the local database.
subcmd_d1__local__seed() {
  subcmd_d1__local__exec --file "$db_seed_path_540ec19"
}

# Seed the database.
subcmd_d1__seed() {
  subcmd_d1__exec --file "$db_seed_path_540ec19"
}

# Seed the preview database.
subcmd_d1__prev__seed() {
  subcmd_d1__prev__exec --file "$db_seed_path_540ec19"
}

# --------------------------------------------------------------------------
# Delete the database
# --------------------------------------------------------------------------

# Calculate the object ID of the Miniflare D1 local database.
subcmd_d1__local__object__id() {
  local unique_key name
  unique_key="miniflare-D1DatabaseObject"
  local name="$(subcmd_d1__id)"
  # Release v3.20230918.0 · cloudflare/miniflare https://github.com/cloudflare/miniflare/releases/tag/v3.20230918.0
  cat <<EOF | subcmd_node --input-type=module
import crypto from "node:crypto";
const key = crypto.createHash("sha256").update("${unique_key}").digest();
const nameHmac = crypto.createHmac("sha256", key).update("${name}").digest().subarray(0, 16);
const hmac = crypto.createHmac("sha256", key).update(nameHmac).digest().subarray(0, 16);
console.log(Buffer.concat([nameHmac, hmac]).toString("hex"));
EOF
}

# List the local database files.
subcmd_d1__local__files() {
  local hash="$(subcmd_d1__local__object__id)"
  find "$TASKS_DIR"/.wrangler -type f -name "$hash.sqlite*"
}

# Delete the local database.
subcmd_d1__local__delete() {
  push_ifs "$newline"
  # shellcheck disable=SC2046
  set -- $(subcmd_d1__local__files)
  pop_ifs
  if test "$#" -gt 0 && test -f "$1"
  then
    if prompt_confirm "Do you really want to remove the database files?" "no"
    then
      rm -f "$@"
      echo "The database files have been deleted." >&2
    else
      echo "The database files were not deleted." >&2
    fi
  else
    echo "No database file found." >&2
  fi
}

# Delete the database.
subcmd_d1__delete() {
  if prompt_confirm "Do you really want to remove the database?" "no"
  then
    wrangler d1 delete "$(subcmd_d1__name)"
  else
    echo "The database was not deleted." >&2
  fi
}

# Delete the preview database.
subcmd_d1__prev__delete() {
  if prompt_confirm "Do you really want to remove the preview database?" "no"
  then
    wrangler d1 delete "$(subcmd_d1__prev__name)"
  else
    echo "The preview database was not deleted." >&2
  fi
}

# --------------------------------------------------------------------------
# Show the difference between the database and the schema file
# --------------------------------------------------------------------------

# Generate schema differences between the database and the schema file.
d1_diff() {
  local mode="$1"
  local current_schema_path="$TEMP_DIR"/13c81f9.sql
  case "$mode" in
    (--local) subcmd_d1__local__schema ;;
    (--top) subcmd_d1__schema ;;
    (--prev) subcmd_d1__prev__schema ;;
  esac | grep -Ev \
    -e "^PRAGMA defer_foreign_keys=.*;$" \
    -e "^DELETE FROM sqlite_sequence;$" \
    >"$current_schema_path"
  sqlite3def --file="$db_schema_path_d4253e5" "$current_schema_path"
}

# Show the difference between the local database and the schema file.
subcmd_d1__local__diff() {
  d1_diff --local
}

# Show the difference between the database and the schema file.
subcmd_d1__diff() {
  d1_diff --top
}

# Show the difference between the preview database and the schema file.
subcmd_d1__prev__diff() {
  d1_diff --prev
}

# --------------------------------------------------------------------------
# Migrate the database
# --------------------------------------------------------------------------

d1_migrate() { # Apply the schema changes to the database.
  local mode="$1"
  local diff_sql_path="$TEMP_DIR"/5e31f47.sql
  case "$mode" in
    (--local) subcmd_d1__local__diff ;;
    (--top) subcmd_d1__diff ;;
    (--prev) subcmd_d1__prev__diff ;;
  esac >"$diff_sql_path"
  if grep -q 'Nothing is modified' "$diff_sql_path"
  then
    echo "No schema changes." >&2
    return 0
  fi
  echo "Applying the schema changes:" >&2
  cat "$diff_sql_path" >&2
  case "$mode" in
    (--local) subcmd_d1__local__exec --file="$diff_sql_path" ;;
    (--top) subcmd_d1__exec --file="$diff_sql_path" ;;
    (--prev) subcmd_d1__prev__exec --file="$diff_sql_path" ;;
  esac
}

# Apply the schema changes to the local D1 database.
subcmd_d1__local__migrate() {
  d1_migrate --local
}

# Apply the schema changes to the D1 database.
subcmd_d1__migrate() {
  d1_migrate --top
}

# Apply the schema changes to the preview D1 database.
subcmd_d1__prev__migrate() {
  d1_migrate --prev
}
