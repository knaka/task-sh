#!/bin/sh
# shellcheck disable=SC3043
test "${guard_500d066+set}" = set && return 0; guard_500d066=x
set -o nounset -o errexit

. ./task-pages.lib.sh
. ./task-yq.lib.sh

# --------------------------------------------------------------------------
# D1 Database
# --------------------------------------------------------------------------

mkdir -p build/

d1_database_name() {
  memoize 9764143 subcmd_yq --exit-status eval '.d1_databases.0.database_name' wrangler.toml
}

task_d1__create() { # Create the remote D1 database. This must be executed only once through the project lifecycle.
  subcmd_wrangler d1 create "$1"
}

task_d1__info() { # Show the information of the remote D1 database.
  subcmd_wrangler d1 info --json "$(d1_database_name)"
}

d1_exec() {
  subcmd_wrangler d1 execute "$(d1_database_name)" "$@"
}

subcmd_d1__exec() { # Execute SQL command in the remote D1 database.
  d1_exec --remote "$@"
}

d1_dump() {
  subcmd_wrangler d1 export "$(d1_database_name)" "$@"
}

task_d1__dump() { # Dump the remote database.
  d1_dump --remote --output=/dev/stdout
}

d1_export_schema() {
  subcmd_wrangler d1 export --no-data "$@" "$(d1_database_name)"
}

task_d1__schema() { # Export the schema of the remote D1 database.
  d1_export_schema --remote --output=build/remote-schema.sql
}

d1_diff() {
  :  
}

task_d1__diff() { # Generate the schema difference between the remote database and the schema file.
  subcmd_wrangler d1 export --remote --no-data --output=build/remote-schema.sql "$database_name"
  rm -f build/remote-schema.db
  subcmd_sqlite3 build/remote-schema.db <build/remote-schema.sql
  cross_run ./cmd-gobin run sqlite3def --file=schema.sql build/remote-schema.db --dry-run > build/remote-diff.sql
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
  d1_exec --local "$@"
}

task_d1__local__schema() { # Export the schema of the development D1 database.
  d1_export_schema --local --output=build/local-schema.sql
}

task_d1__local__dump() { # Dump the development database.
  subcmd_wrangler d1 export --local --output=/dev/stdout "$database_name"
}

task_d1__local__drop() { # Drop the development database.
  find .wrangler -type f -name "*.sqlite*" -print0 | xargs -0 -n1 rm -f
}

task_d1__local__create() { # Create the development database.
  subcmd_d1__local__exec --command "SELECT current_timestamp"
}

task_d1__local__diff() { # Generate the schema difference between the development database and the schema file.
  task_d1__local__schema
  rm -f build/dev-schema.db
  subcmd_sqlite3 build/dev-schema.db < build/dev-schema.sql
  cross_run ./cmd-gobin run sqlite3def --file=schema.sql build/dev-schema.db --dry-run > build/dev-diff.sql
  cat build/dev-diff.sql
}

task_d1__local__migrate() { # Apply the schema changes to the development database.
  task_d1__local__diff
  if test "$(sha1sum build/dev-diff.sql | field 1)" = e7efbf38cff7d12493cbe795586c588dccb332f4
  then
    echo "No schema changes."
    return 0
  fi
  subcmd_d1__local__exec --file=build/dev-diff.sql
}

task_d1__local__seed() { # Seed the development database.
  subcmd_d1__local__exec --file=seed.sql
}
