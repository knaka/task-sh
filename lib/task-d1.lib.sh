#!/bin/sh
test "${guard_500d066+set}" = set && return 0; guard_500d066=x

. ./task-pages.lib.sh
. ./task-yq.lib.sh
. ./task-sqldef.lib.sh
. ./task-sqlite3.lib.sh

db_schema_path_d4253e5="./schema.sql"

set_db_schema_path() {
  db_schema_path_d4253e5="$1"
}

db_seed_path_540ec19="./seed.sql"

set_db_seed_path() {
  db_seed_path_540ec19="$1"
}

# --------------------------------------------------------------------------
# D1 Database
# --------------------------------------------------------------------------

mkdir -p build/

task_d1__list() { # List the remote D1 databases.
  subcmd_wrangler d1 list
}

get_d1_name() {
  memoize 9764143 subcmd_yq --exit-status eval '.d1_databases.0.database_name' ./wrangler.toml
}

subcmd_d1__create() { # Create the remote D1 database. This must be executed only once through the project lifecycle.
  subcmd_wrangler d1 create "$1"
}

task_d1__info() { # Show the information of the remote D1 database.
  subcmd_wrangler d1 info --json "$(get_d1_name)"
}

d1_exec() {
  subcmd_wrangler d1 execute "$(get_d1_name)" "$@"
}

subcmd_d1__exec() { # Execute SQL command in the remote D1 database.
  d1_exec --remote "$@"
}

subcmd_d1__file__exec() { # Execute SQL file in the remote D1 database.
  subcmd_d1__exec --file "$@"
}

subcmd_d1__command__exec() { # Execute SQL command in the remote D1 database.
  subcmd_d1__exec --command "$@"
}

d1_dump() {
  subcmd_wrangler d1 export "$(get_d1_name)" "$@"
}

task_d1__dump() { # Dump the remote database.
  d1_dump --remote --output=/dev/stdout
}

d1_export_schema() {
  subcmd_wrangler d1 export --no-data "$@" "$(get_d1_name)"
}

task_d1__schema() { # Export the schema of the remote D1 database.
  d1_export_schema --remote --output=build/remote-schema.sql
}

d1_diff() {
  :  
}

task_d1__diff() { # Generate the schema difference between the remote database and the schema file.
  subcmd_wrangler d1 export --remote --no-data --output=build/remote-schema.sql "$(get_d1_name)"
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

local_schema_path_6b4fb03="./ "
local_diff_path_b5c5b11="./build/local-diff.sql"

subcmd_d1__local__exec() { # Execute SQL command in the development D1 database.
  d1_exec --local "$@"
}

subcmd_d1__local__file__exec() { # Execute SQL file in the development D1 database.
  subcmd_d1__local__exec --file "$@"
}

subcmd_d1__local__command__exec() { # Execute SQL command in the development D1 database.
  subcmd_d1__local__exec --command "$@"
}

task_d1__local__schema() { # Export the schema of the development D1 database.
  d1_export_schema --local --output="$local_schema_path_6b4fb03"
}

task_d1__local__dump() { # Dump the development database.
  subcmd_wrangler d1 export --local --output=/dev/stdout "$(get_d1_name)"
}

task_d1__local__drop() { # Drop the development database.
  find .wrangler -type f -name "*.sqlite*" -print0 | xargs -0 -n1 rm -f
}

task_d1__local__create() { # Create the development database.
  subcmd_d1__local__exec --command "SELECT current_timestamp"
}

task_d1__local__diff() { # Generate the schema difference between the development database and the schema file.
  task_d1__local__schema
  rm -f build/local-schema.db
  subcmd_sqlite3 build/local-schema.db <"$local_schema_path_6b4fb03"
  subcmd_sqlite3def --file="$db_schema_path_d4253e5" build/local-schema.db --dry-run >"$local_diff_path_b5c5b11"
  cat "$local_diff_path_b5c5b11"
}

task_d1__local__migrate() { # Apply the schema changes to the development database.
  task_d1__local__diff
  if test "$(sha1sum "$local_diff_path_b5c5b11" | field 1)" = e7efbf38cff7d12493cbe795586c588dccb332f4
  then
    echo "No schema changes." >&2
    return 0
  fi
  subcmd_d1__local__exec --file="$local_diff_path_b5c5b11"
}

task_d1__local__seed() { # Seed the development database.
  subcmd_d1__local__file__exec "$db_seed_path_540ec19"
}
