# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_ce1c863-}" = true && return 0; sourced_ce1c863=true

. ./task-pages.lib.sh
. ./task-yq.lib.sh
. ./task-sqldef.lib.sh
. ./task-sqlite3.lib.sh
. ./task-node.lib.sh

db_schema_path_d4253e5="$TASKS_DIR/schema.sql"

set_db_schema_path() {
  db_schema_path_d4253e5="$1"
}

db_seed_path_540ec19="$TASKS_DIR/seed.sql"

set_db_seed_path() {
  db_seed_path_540ec19="$1"
}

mkdir -p ./build/

# --------------------------------------------------------------------------
# Parse the Wrangler configuration file
# --------------------------------------------------------------------------

subcmd_d1__binding() { # [index = 0] Show the binding name of the D1 database configured in the configuration file.
  local index="${1:-0}"
  subcmd_yq --exit-status eval ".d1_databases.$index.binding" "$wrangler_toml_path"
}

subcmd_d1__name() { # [index = 0] Show the name of the D1 database configured in the configuration file.
  local index="${1:-0}"
  subcmd_yq --exit-status eval ".d1_databases.$index.database_name" "$wrangler_toml_path"
}

subcmd_d1__id() { # [index = 0] Show the ID of the D1 database configured in the configuration file.
  local index="${1:-0}"
  subcmd_yq --exit-status eval ".d1_databases.$index.database_id" "$wrangler_toml_path"
}

# --------------------------------------------------------------------------
# Only for remote
# --------------------------------------------------------------------------

subcmd_d1__remote__list() { # List the remote D1 databases.
  subcmd_wrangler d1 list
}

subcmd_d1__remote__info() { # Show the information of the remote D1 database.
  subcmd_wrangler d1 info --json "$(subcmd_d1__name)"
}

# --------------------------------------------------------------------------
# Create the D1 database
# --------------------------------------------------------------------------

subcmd_d1__local__create() { # Create the local D1 database.
  subcmd_d1__local__exec --command "SELECT null"
}

subcmd_d1__remote__create() { # Create the remote D1 database. This must be executed only once through the project lifecycle.
  subcmd_wrangler d1 create "$@"
}

# --------------------------------------------------------------------------
# Execute SQL commands
# --------------------------------------------------------------------------

subcmd_d1__exec() { # Execute SQL command in the D1 database.
  subcmd_wrangler d1 execute "$(subcmd_d1__name)" "$@"
}

subcmd_d1__local__exec() { # Execute SQL command in the local D1 database.
  subcmd_d1__exec --local "$@"
}

subcmd_d1__remote__exec() { # Execute SQL command in the remote D1 database.
  subcmd_d1__exec --remote "$@"
}

# --------------------------------------------------------------------------
# Dump the database
# --------------------------------------------------------------------------

subcmd_d1__dump() { # Dump the database.
  local output_file_path="$TEMP_DIR"/dump.sql
  subcmd_wrangler d1 export "$(subcmd_d1__name)" --output="$output_file_path"
  cat "$output_file_path"
} 


subcmd_d1__local__dump() { # Dump the local database.
  subcmd_d1__dump --local
}

subcmd_d1__remote__dump() { # Dump the remote database.
  subcmd_d1__dump --remote
}

# --------------------------------------------------------------------------
# Get the schema of the database
# --------------------------------------------------------------------------

subcmd_d1__schema() { # Export the schema of the D1 database.
  local schema_file_path="$(temp_dir_path)/"schema.sql
  subcmd_wrangler d1 export --no-data "$@" "$(subcmd_d1__name)" --output="$schema_file_path" 1>&2
  cat "$schema_file_path"
}

subcmd_d1__local__schema() { # Export the schema of the local D1 database.
  subcmd_d1__schema --local
}

subcmd_d1__remote__schema() { # Export the schema of the remote D1 database.
  subcmd_d1__schema --remote
}

# --------------------------------------------------------------------------
# Seed the database
# --------------------------------------------------------------------------

subcmd_d1__local__seed() { # Seed the local database.
  subcmd_d1__local__exec --file "$db_seed_path_540ec19"
}

subcmd_d1__remote_seed() { # Seed the remote database.
  subcmd_d1__remote__exec --file "$db_seed_path_540ec19"
}

# --------------------------------------------------------------------------
# Delete the database
# --------------------------------------------------------------------------

subcmd_d1__local__object__id() { # Calculate the object ID of the Miniflare D1 local database.
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

subcmd_d1__local__files() { # List the local database files.
  local hash="$(subcmd_d1__local__object__id)"
  find "$TASKS_DIR"/.wrangler -type f -name "$hash.sqlite*"
}

subcmd_d1__local__delete() { # Delete the local database.
  push_ifs "$newline"
  # shellcheck disable=SC2046
  set -- $(subcmd_d1__local__files)
  pop_ifs
  if test "$#" -gt 0 && test -f "$1"
  then
    if prompt_confirm "Do you really want to remove the database files?" "no"
    then
      rm -f "$@"
      echo "The database files are deleted." >&2
    else
      echo "The database files are not deleted." >&2
    fi
  else
    echo "No database file found." >&2
  fi
}

subcmd_d1__remote__delete() { # Delete the remote database.
  if prompt_confirm "Do you really want to remove the remote database?" "no"
  then
    subcmd_wrangler d1 delete "$(subcmd_d1__name)"
  else
    echo "The remote database is not deleted." >&2
  fi
}

# --------------------------------------------------------------------------
# Show the difference between the database and the schema file
# --------------------------------------------------------------------------

subcmd_d1__diff() { # Generate the schema difference between the development database and the schema file.
  local mode="$1"
  local db_file_path="$(temp_dir_path)/13c81f9"

  subcmd_d1__schema "$mode" | subcmd_sqlite3 "$db_file_path"
  # `--dry-run` prints the SQL commands that would be executed to idempotently apply the schema changes.
  subcmd_sqlite3def --file="$db_schema_path_d4253e5" "$db_file_path" --dry-run
}

subcmd_d1__local__diff() {
  subcmd_d1__diff --local
}

subcmd_d1__remote__diff() {
  subcmd_d1__diff --remote
}

# --------------------------------------------------------------------------
# Migrate the database
# --------------------------------------------------------------------------

subcmd_d1__migrate() { # Apply the schema changes to the development database.
  local mode="$1"
  local diff_sql_path="$TEMP_DIR"/5e31f47

  subcmd_d1__diff "$mode" >"$diff_sql_path"
  if grep -q 'Nothing is modified' "$diff_sql_path"
  then
    echo "No schema changes." >&2
    return 0
  fi
  echo "Applying the schema changes:" >&2
  cat "$diff_sql_path" >&2
  subcmd_d1__exec "$mode" --file="$diff_sql_path"
}

subcmd_d1__local__migrate() {
  subcmd_d1__migrate --local
}

subcmd_d1__remote__migrate() {
  subcmd_d1__migrate --remote
}
