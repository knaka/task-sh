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

# ==========================================================================
# Get values from Wrangler configuration file

# Show the binding name of the D1 database configured in the configuration file.
subcmd_d1__binding() {
  init_cf_env_once ""
  yq --exit-status eval ".env.\"$CLOUDFLARE_ENV\".d1_databases.0.binding // .d1_databases.0.binding" "$wrangler_toml_path"
}

# Show the binding name of the preview D1 database configured in the configuration file.
subcmd_d1__prev__binding() {
  init_cf_env_once "preview"
  subcmd_d1__binding
}

# Show the binding name of the test D1 database configured in the configuration file.
subcmd_d1__test__binding() {
  init_cf_env_once "test"
  subcmd_d1__binding
}

# Show the name of the D1 database configured in the configuration file.
subcmd_d1__name() {
  init_cf_env_once ""
  yq --exit-status eval ".env.\"$CLOUDFLARE_ENV\".d1_databases.0.database_name // .d1_databases.0.database_name" "$wrangler_toml_path"
}

# Show the name of the preview D1 database configured in the configuration file.
subcmd_d1__prev__name() {
  init_cf_env_once "preview"
  subcmd_d1__name
}

# Show the name of the test D1 database configured in the configuration file.
subcmd_d1__test__name() {
  init_cf_env_once "test"
  subcmd_d1__name
}

# Show the ID of the D1 database configured in the configuration file.
subcmd_d1__id() {
  init_cf_env_once ""
  yq --exit-status eval ".env.\"$CLOUDFLARE_ENV\".d1_databases.0.database_id // .d1_databases.0.database_id" "$wrangler_toml_path"
}

# Show the ID of the preview D1 database configured in the configuration file.
subcmd_d1__prev__id() {
  init_cf_env_once "preview"
  subcmd_d1__id
}

# Show the ID of the test D1 database configured in the configuration file.
subcmd_d1__test__id() {
  init_cf_env_once "test"
  subcmd_d1__id
}

# ==========================================================================
# Tasks for Cloudflare's global D1 services

# List all D1 databases.
subcmd_d1__list() {
  wrangler d1 list
}

# Show the information for the D1 database.
subcmd_d1__info() {
  init_cf_env_once ""
  wrangler d1 info --json --env "$CLOUDFLARE_ENV" "$(subcmd_d1__name)"
}

# Show the information for the preview D1 database.
subcmd_d1__prev__info() {
  init_cf_env_once "preview"
  subcmd_d1__info
}

# Create a new D1 database. This must be executed only once during the project lifecycle.
subcmd_d1__create() {
  init_cf_env_once ""
  wrangler d1 create --env "$CLOUDFLARE_ENV" "$@"
}

# Create a new preview D1 database. This must be executed only once during the project lifecycle.
subcmd_d1__prev__create() {
  init_cf_env_once "preview"
  subcmd_d1__create "$@"
}

# ==========================================================================
# Execute SQL commands

d1_exec() {
  wrangler d1 --env "$CLOUDFLARE_ENV" execute "$(subcmd_d1__name)" "$@"
}

# Execute SQL command in the local D1 database.
subcmd_d1__local__exec() {
  init_cf_env_once ""
  d1_exec --local "$@"
}

# Execute SQL command in the local test D1 database.
subcmd_d1__test__exec() {
  init_cf_env_once "test"
  subcmd_d1__local__exec "$@"
}

# Execute SQL command in the D1 database.
subcmd_d1__exec() {
  init_cf_env_once ""
  d1_exec --remote "$@"
}

# Execute SQL command in the preview D1 database.
subcmd_d1__prev__exec() {
  init_cf_env_once "preview"
  subcmd_d1__exec "$@"
}

# ==========================================================================
# Dump the database

d1_dump() {
  local output_file_path="$TEMP_DIR"/dump.sql
  wrangler d1 export --env "$CLOUDFLARE_ENV" --output="$output_file_path" "$@" "$(subcmd_d1__name)"
  cat "$output_file_path"
} 

# Dump the local D1 database.
subcmd_d1__local__dump() {
  init_cf_env_once ""
  d1_dump --local "$@"
}

# Dump the local test D1 database.
subcmd_d1__test__dump() {
  init_cf_env_once "test"
  subcmd_d1__local__dump "$@"
}

# Dump the database.
subcmd_d1__dump() {
  init_cf_env_once ""
  d1_dump --remote "$@"
}

# Dump the preview database.
subcmd_d1__prev__dump() {
  init_cf_env_once "preview"
  subcmd_d1__dump "$@"
}

# ==========================================================================
# Get the schema of the database

d1_schema() {
  local schema_file_path="$TEMP_DIR"/schema.sql 
  wrangler d1 export --env "$CLOUDFLARE_ENV" --no-data "$@" --output="$schema_file_path" "$(subcmd_d1__name)" 1>&2
  cat "$schema_file_path"
}

# Export the schema from the local D1 database.
subcmd_d1__local__schema() {
  init_cf_env_once ""
  d1_schema --local
}

# Export the schema from the D1 database.
subcmd_d1__schema() {
  init_cf_env_once ""
  d1_schema --remote
}

# Export the schema from the preview D1 database.
subcmd_d1__prev__schema() {
  init_cf_env_once "preview"
  subcmd_d1__schema
}

# ==========================================================================
# Seed the database

d1_seed() {
  d1_exec "$@" --file "$db_seed_path_540ec19"
}

# Seed the local database.
subcmd_d1__local__seed() {
  init_cf_env_once ""
  d1_seed --local
}

# Seed the local test database.
subcmd_d1__test__seed() {
  init_cf_env_once "test"
  d1_seed --local
}

# Seed the database.
subcmd_d1__seed() {
  init_cf_env_once ""
  d1_seed --remote
}

# Seed the preview database.
subcmd_d1__prev__seed() {
  init_cf_env_once "preview"
  subcmd_d1__seed
}

# ==========================================================================
# Delete the database

d1_local_object_id() {
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

# Calculate the object ID of the Miniflare D1 local database.
subcmd_d1__local__object__id() {
  init_cf_env_once ""
  d1_local_object_id
}

# Calculate the object ID of the Miniflare D1 local test database.
subcmd_d1__test__object__id() {
  init_cf_env_once "test"
  subcmd_d1__local__object__id
}

d1_local_files() {
  local hash="$(subcmd_d1__local__object__id)"
  find "$PROJECT_DIR"/.wrangler -type f -name "$hash.sqlite*"
}

# List the local database files.
subcmd_d1__local__files() {
  init_cf_env_once ""
  d1_local_files
}

# List the local test database files.
subcmd_d1__test__files() {
  init_cf_env_once "test"
  subcmd_d1__local__files
}

# Delete the local database.
subcmd_d1__local__delete() {
  init_cf_env_once ""
  local force=false
  if test $# -gt 0 && test "$1" = "--force"
  then
    force=true
  fi
  # shellcheck disable=SC2046
  set -- $(d1_local_files)
  if test $# -gt 0 && test -f "$1"
  then
    if "$force" || prompt_confirm "Do you really want to remove the database files?" "no"
    then
      rm -f "$@"
      echo "The database files have been deleted." >&2
    else
      echo "The database files were not deleted." >&2
      return 1
    fi
  else
    echo "No database file found." >&2
  fi
}

# Delete the local test database.
subcmd_d1__test__delete() {
  init_cf_env_once "test"
  subcmd_d1__local__delete "$@"
}

# Delete the database.
subcmd_d1__delete() {
  init_cf_env_once ""
  local s=
  if test -n "$CLOUDFLARE_ENV"
  then
    s="$CLOUDFLARE_ENV "
  fi
  if prompt_confirm "Do you really want to remove the ${s}database?" "no"
  then
    wrangler d1 delete --env "$CLOUDFLARE_ENV" "$(subcmd_d1__name)"
  else
    echo "The ${s}database was not deleted." >&2
    return 1
  fi
}

# Delete the preview database.
subcmd_d1__prev__delete() {
  init_cf_env_once "preview"
  subcmd_d1__delete "$@"
}

# ==========================================================================
# Show the difference between the database and the schema file

# Generate schema differences between the database and the schema file.
d1_diff() {
  local current_schema_path="$TEMP_DIR"/13c81f9.sql
  d1_schema "$1" \
  | grep -Ev \
    -e "^PRAGMA defer_foreign_keys=.*;$" \
    -e "^DELETE FROM sqlite_sequence;$" \
  >"$current_schema_path" || :
  sqlite3def --file="$db_schema_path_d4253e5" "$current_schema_path"
}

# Show the difference between the local database and the schema file.
subcmd_d1__local__diff() {
  init_cf_env_once ""
  d1_diff --local
}

# Show the difference between the local test database and the schema file.
subcmd_d1__test__diff() {
  init_cf_env_once "test"
  d1_diff --local
}

# Show the difference between the database and the schema file.
subcmd_d1__diff() {
  init_cf_env_once ""
  d1_diff --remote
}

# Show the difference between the preview database and the schema file.
subcmd_d1__prev__diff() {
  init_cf_env_once preview
  subcmd_d1__diff
}

# ==========================================================================
# Migrate the database

# Apply the schema changes to the database.
d1_migrate() {
  local diff_sql_path="$TEMP_DIR"/5e31f47.sql
  d1_diff "$1" >"$diff_sql_path"
  if grep -q 'Nothing is modified' "$diff_sql_path"
  then
    echo "No schema changes." >&2
    return 0
  fi
  echo "Applying the schema changes:" >&2
  cat "$diff_sql_path" >&2
  d1_exec "$1" --file="$diff_sql_path"
}

# Apply the schema changes to the local D1 database.
subcmd_d1__local__migrate() {
  init_cf_env_once ""
  d1_migrate --local
}

# Apply the schema changes to the local test D1 database.
subcmd_d1__test__migrate() {
  init_cf_env_once "test"
  subcmd_d1__local__migrate
}

# Apply the schema changes to the D1 database.
subcmd_d1__migrate() {
  init_cf_env_once ""
  d1_migrate --remote
}

# Apply the schema changes to the preview D1 database.
subcmd_d1__prev__migrate() {
  init_cf_env_once "preview"
  subcmd_d1__migrate
}
