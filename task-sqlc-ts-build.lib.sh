# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_ca6b512-}" = true && return 0; sourced_ca6b512=true

. ./task.sh
. ./task-node.lib.sh
. ./task-javy.lib.sh

# Currently, the published WASM on sqlc.dev does not support SQLite3.
desc_sqlc__ts__build="Builds the gen-typescript plugin."
task_sqlc__ts__build() {
  first_call 121be92 || return 0
  if test -r ./build/sqlc-gen-typescript/examples/plugin.wasm
  then
    return 0
  fi
  # https://github.com/sqlc-dev/sqlc-gen-typescript/blob/main/.github/workflows/ci.yml
  (
    cd build
    if ! test -d ./sqlc-gen-typescript
    then
      invoke git clone https://github.com/sqlc-dev/sqlc-gen-typescript.git
    fi
    cd sqlc-gen-typescript
    subcmd_npm install
    subcmd_npx tsc --noEmit
    subcmd_npx esbuild --bundle src/app.ts --tree-shaking=true --format=esm --target=es2020 --outfile=out.js
    subcmd_javy build out.js -o examples/plugin.wasm
  )
}
