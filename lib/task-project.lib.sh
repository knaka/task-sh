#!/bin/sh
test "${guard_fb8b13a+set}" = set && return 0; guard_fb8b13a=-

. ./task.sh
. ./task-bun.lib.sh
. ./task-sqlc.lib.sh
  set_sqlc_version "v1.27.0"
. ./task-sqlc-ts.lib.sh
. ./task-pages.lib.sh
  # Only “Catch All” routes are the transpile targets.
  set_pages_functions_src_pattern "./src-pages/functions/**/[*.ts"
. ./task-astro.lib.sh

subcmd_test() { # Run tests.
  subcmd_bun test "$@"
}

task_db__gen() { # Generate the database access layer (./db/sqlcgen/*).
  subcmd_sqlc generate --file ./db/sqlc.yaml  
  # Then, rewrite the generated file.
  rewrite_sqlcgen_ts ./db/sqlcgen/*.ts
}

task_gen() { # Generate files.
  task_db__gen
}
