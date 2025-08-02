# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_ce1c863-}" = true && return 0; sourced_ce1c863=true

. ./task-yq.lib.sh
. ./task-sqldef.lib.sh
. ./task-sqlite3.lib.sh
. ./task-node.lib.sh
. ./task-cloudflare.lib.sh

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

subcmd_d1__prod__binding() { # [index = 0] Show the binding name of the production D1 database configured in the configuration file.
  local index="${1:-0}"
  yq --exit-status eval ".env.production.d1_databases.$index.binding // .d1_databases.$index.binding" "$wrangler_toml_path"
}

subcmd_d1__prev__binding() { # [index = 0] Show the binding name of the preview D1 database configured in the configuration file.
  local index="${1:-0}"
  yq --exit-status eval ".env.preview.d1_databases.$index.binding // .d1_databases.$index.binding" "$wrangler_toml_path"
}

subcmd_d1__prod__name() { # [index = 0] Show the production name of the D1 database configured in the configuration file.
  local index="${1:-0}"
  yq --exit-status eval ".env.production.d1_databases.$index.database_name // .d1_databases.$index.database_name" "$wrangler_toml_path"
}

subcmd_d1__prev__name() { # [index = 0] Show the preview name of the D1 database configured in the configuration file.
  local index="${1:-0}"
  yq --exit-status eval ".env.preview.d1_databases.$index.database_name // .d1_databases.$index.database_name" "$wrangler_toml_path"
}

subcmd_d1__prod__id() { # [index = 0] Show the ID of the production D1 database configured in the configuration file.
  local index="${1:-0}"
  yq --exit-status eval ".env.production.d1_databases.$index.database_id // .d1_databases.$index.database_id" "$wrangler_toml_path"
}

subcmd_d1__prev__id() { # [index = 0] Show the ID of the preview D1 database configured in the configuration file.
  local index="${1:-0}"
  yq --exit-status eval ".env.preview.d1_databases.$index.database_id // .d1_databases.$index.database_id" "$wrangler_toml_path"
}

# --------------------------------------------------------------------------
# Tasks for Cloudflare's global D1 services
# --------------------------------------------------------------------------

subcmd_d1__list() { # List the D1 databases.
  subcmd_wrangler d1 list
}

subcmd_d1__info() { # Show the information of the production D1 database.
  subcmd_wrangler d1 info --json "$(subcmd_d1__prod__name)"
}

subcmd_d1__create() { # Create a new D1 database. This must be executed only once through the project lifecycle.
  subcmd_wrangler d1 create "$@"
}

# --------------------------------------------------------------------------
# Execute SQL commands
# --------------------------------------------------------------------------

subcmd_d1__local__exec() { # Execute SQL command in the local D1 database.
  subcmd_wrangler d1 execute --local "$(subcmd_d1__prod__name)" "$@"
}

subcmd_d1__prod__exec() { # Execute SQL command in the production D1 database.
  subcmd_wrangler d1 execute --remote "$(subcmd_d1__prod__name)" "$@"
}

subcmd_d1__prev__exec() { # Execute SQL command in the preview D1 database.
  subcmd_wrangler d1 --env preview execute --remote "$(subcmd_d1__prev__name)" "$@"
}

# --------------------------------------------------------------------------
# Dump the database
# --------------------------------------------------------------------------

subcmd_d1__dump() { # Dump the database.
  local output_file_path="$TEMP_DIR"/dump.sql
  subcmd_wrangler d1 export --output="$output_file_path" "$@"
  cat "$output_file_path"
} 

subcmd_d1__local__dump() { # Dump the local database.
  subcmd_d1__dump --local "$(subcmd_d1__prod__name)"
}

subcmd_d1__prod__dump() { # Dump the production database.
  subcmd_d1__dump --remote "$(subcmd_d1__prod__name)"
}

subcmd_d1__prev__dump() { # Dump the preview database.
  subcmd_d1__dump --env preview --remote "$(subcmd_d1__prev__name)"
}

# --------------------------------------------------------------------------
# Get the schema of the database
# --------------------------------------------------------------------------

subcmd_d1__schema() { # Export the schema of the D1 database.
  local schema_file_path="$TEMP_DIR"/schema.sql 
  subcmd_wrangler d1 export --no-data "$@" --output="$schema_file_path" 1>&2
  cat "$schema_file_path"
}

subcmd_d1__local__schema() { # Export the schema of the local D1 database.
  subcmd_d1__schema --local "$(subcmd_d1__prod__name)"
}

subcmd_d1__prod__schema() { # Export the schema of the production D1 database.
  subcmd_d1__schema --remote "$(subcmd_d1__prod__name)"
}

subcmd_d1__prev__schema() { # Export the schema of the preview D1 database.
  subcmd_d1__schema --env preview --remote "$(subcmd_d1__prev__name)"
}

# --------------------------------------------------------------------------
# Seed the database
# --------------------------------------------------------------------------

subcmd_d1__local__seed() { # Seed the local database.
  subcmd_d1__local__exec --file "$db_seed_path_540ec19"
}

subcmd_d1__prod__seed() { # Seed the production database.
  subcmd_d1__prod__exec --file "$db_seed_path_540ec19"
}

subcmd_d1__prev__seed() { # Seed the preview database.
  subcmd_d1__prev__exec --file "$db_seed_path_540ec19"
}

# --------------------------------------------------------------------------
# Delete the database
# --------------------------------------------------------------------------

subcmd_d1__local__object__id() { # Calculate the object ID of the Miniflare D1 local database.
  local unique_key name
  unique_key="miniflare-D1DatabaseObject"
  local name="$(subcmd_d1__prod__id)"
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

subcmd_d1__prod__delete() { # Delete the production database.
  if prompt_confirm "Do you really want to remove the production database?" "no"
  then
    subcmd_wrangler d1 delete "$(subcmd_d1__prod__name)"
  else
    echo "The production database is not deleted." >&2
  fi
}

subcmd_d1__prev__delete() { # Delete the preview database.
  if prompt_confirm "Do you really want to remove the preview database?" "no"
  then
    subcmd_wrangler d1 delete "$(subcmd_d1__prev__name)"
  else
    echo "The preview database is not deleted." >&2
  fi
}

# --------------------------------------------------------------------------
# Show the difference between the database and the schema file
# --------------------------------------------------------------------------

# Generate the schema difference between the development database and the schema file.
d1_diff() {
  local mode="$1"
  local db_file_path="$TEMP_DIR"/13c81f9

  case "$mode" in
    (--local) subcmd_d1__local__schema ;;
    (--prod) subcmd_d1__prod__schema ;;
    (--prev) subcmd_d1__prev__schema ;;
  esac | subcmd_sqlite3 "$db_file_path"
  # `--dry-run` prints the SQL commands that would be executed to idempotently apply the schema changes.
  subcmd_sqlite3def --file="$db_schema_path_d4253e5" "$db_file_path" --dry-run
  rm -f "$db_file_path"
}

subcmd_d1__local__diff() { # Show the difference between the local database and the schema file.
  d1_diff --local
}

subcmd_d1__prod__diff() { # Show the difference between the production database and the schema file.
  d1_diff --prod
}

subcmd_d1__prev__diff() { # Show the difference between the preview database and the schema file.
  d1_diff --prev
}

# --------------------------------------------------------------------------
# Migrate the database
# --------------------------------------------------------------------------

d1_migrate() { # Apply the schema changes to the development database.
  local mode="$1"
  local diff_sql_path="$TEMP_DIR"/5e31f47

  case "$mode" in
    (--local) subcmd_d1__local__diff ;;
    (--prod) subcmd_d1__prod__diff ;;
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
    (--prod) subcmd_d1__prod__exec --file="$diff_sql_path" ;;
    (--prev) subcmd_d1__prev__exec --file="$diff_sql_path" ;;
  esac
}

subcmd_d1__local__migrate() { # Apply the schema changes to the local D1 database.
  d1_migrate --local
}

subcmd_d1__prod__migrate() { # Apply the schema changes to the production D1 database.
  d1_migrate --prod
}

subcmd_d1__prev__migrate() { # Apply the schema changes to the preview D1 database.
  d1_migrate --prev
}
