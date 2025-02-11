# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_ce1c863-}" = true && return 0; sourced_ce1c863=true

. ./task-pages.lib.sh
. ./task-yq.lib.sh
. ./task-sqldef.lib.sh
. ./task-sqlite3.lib.sh
. ./task-node.lib.sh

db_schema_path_d4253e5="$SCRIPT_DIR/schema.sql"

set_db_schema_path() {
  db_schema_path_d4253e5="$1"
}

db_seed_path_540ec19="$SCRIPT_DIR/seed.sql"

set_db_seed_path() {
  db_seed_path_540ec19="$1"
}

# --------------------------------------------------------------------------
# D1 Database
# --------------------------------------------------------------------------

mkdir -p build/

subcmd_d1__exec() {
  subcmd_wrangler d1 execute "$(subcmd_d1__name)" "$@"
}

: "${wrangler_toml_path:=$SCRIPT_DIR/wrangler.toml}"

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
# Remote D1 Database
# --------------------------------------------------------------------------

task_d1__remote__list() { # List the remote D1 databases.
  subcmd_wrangler d1 list
}

subcmd_d1__remote__create() { # Create the remote D1 database. This must be executed only once through the project lifecycle.
  subcmd_wrangler d1 create "$1"
}

task_d1__remote__info() { # Show the information of the remote D1 database.
  subcmd_wrangler d1 info --json "$(subcmd_d1__name)"
}

subcmd_d1__remote__exec() { # Execute SQL command in the remote D1 database.
  subcmd_d1__exec --remote "$@"
}

task_d1__remote__dump() { # Dump the remote database.
  subcmd_wrangler d1 export "$(subcmd_d1__name)" --remote --output=/dev/stdout
}

task_d1__schema() {
  local schema_file_path
  schema_file_path="$(temp_dir_path)/schema.sql"
  subcmd_wrangler d1 export --no-data "$@" "$(subcmd_d1__name)" --output="$schema_file_path" 1>&2
  cat "$schema_file_path"
}

task_d1__remote__schema() { # Export the schema of the remote D1 database.
  task_d1__schema --remote
}

task_d1__diff() { # Generate the schema difference between the remote database and the schema file.
  subcmd_wrangler d1 export --remote --no-data --output=build/remote-schema.sql "$(subcmd_d1__name)"
  rm -f build/remote-schema.db
  subcmd_sqlite3 build/remote-schema.db <build/remote-schema.sql
  subcmd_sqlite3def --file=schema.sql build/remote-schema.db --dry-run > build/remote-diff.sql
  cat build/remote-diff.sql
}

task_d1__migrate() { # Apply the schema changes to the remote database.
  task_d1__diff
  if test "$(sha1sum build/remote-diff.sql | field 1)" = e7efbf38cff7d12493cbe795586c588dccb332f4
  then
    echo "No schema changes."
    return 0
  fi
  subcmd_d1__exec --file=build/remote-diff.sql
}

task_d1__seed() { # Seed the remote database.
  subcmd_d1__exec --file=seed.sql
}

# --------------------------------------------------------------------------
# Development Local D1 Database
# --------------------------------------------------------------------------

subcmd_d1__local__exec() { # Execute SQL command in the development D1 database.
  subcmd_d1__exec --local "$@"
}

task_d1__local__schema() { # Export the schema of the development D1 database.
  task_d1__schema --local
}

task_d1__local__dump() { # Dump the development database.
  subcmd_wrangler d1 export --local --output=/dev/stdout "$(subcmd_d1__name)"
}

subcmd_d1__local__object__id() { # Calculate the object ID of the Miniflare D1 database object.
  # Release v3.20230918.0 · cloudflare/miniflare https://github.com/cloudflare/miniflare/releases/tag/v3.20230918.0
  local unique_key name
  unique_key="miniflare-D1DatabaseObject"
  local name="$(subcmd_d1__id)"
  cat <<EOF | subcmd_node --input-type=module
import crypto from "node:crypto";
const key = crypto.createHash("sha256").update("${unique_key}").digest();
const nameHmac = crypto.createHmac("sha256", key).update("${name}").digest().subarray(0, 16);
const hmac = crypto.createHmac("sha256", key).update(nameHmac).digest().subarray(0, 16);
console.log(Buffer.concat([nameHmac, hmac]).toString("hex"));
EOF
}

subcmd_d1__local__files() {
  local hash="$(subcmd_d1__local__object__id)"
  find "$SCRIPT_DIR"/.wrangler -type f -name "$hash.sqlite*"
}

task_d1__local__drop() { # Drop the development database.
  local hash
  local response
  hash="$(subcmd_node "$SCRIPT_DIR"/scripts/gen-hash.js miniflare-D1DatabaseObject "$(subcmd_d1__id)")"
  push_ifs "$newline"
  # shellcheck disable=SC2046
  set -- $(find "$SCRIPT_DIR"/.wrangler -type f -name "$hash.sqlite*" -print)
  pop_ifs
  if test "$#" -gt 0
  then
    response="$(prompt "Do you really want to drop the database files? [y/N]" "N")" 
    if test "$response" = "y"
    then
      rm -f "$@"
    fi
  else
    echo "No database file found." >&2
  fi
}

task_d1__local__create() { # Create the development database.
  subcmd_d1__local__exec --command "SELECT null"
}

task_d1__local__diff() { # Generate the schema difference between the development database and the schema file.
  local db_file_path="$(temp_dir_path)/13c81f9"

  task_d1__local__schema | subcmd_sqlite3 "$db_file_path"
  # `--dry-run` prints the SQL commands that would be executed to idempotently apply the schema changes.
  subcmd_sqlite3def --file="$db_schema_path_d4253e5" "$db_file_path" --dry-run
}

task_d1__local__migrate() { # Apply the schema changes to the development database.
  local diff_sql_path="$(temp_dir_path)"/5e31f47

  task_d1__local__diff >"$diff_sql_path"
  if grep -q 'Nothing is modified' "$diff_sql_path"
  then
    echo "No schema changes." >&2
    return 0
  fi
  subcmd_d1__local__exec --file="$diff_sql_path"
}

task_d1__local__seed() { # Seed the development database.
  subcmd_d1__local__exec --file "$db_seed_path_540ec19"
}
